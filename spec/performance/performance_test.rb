require 'spec_helper'

describe ActiveRecordFlorder do
  def create_model(position)
    DESCMovable.create(position: position)
  end

  def fetch_ordered
    DESCMovable.ordered
  end

  def create_models
    500.times do |p|
      create_model(p)
    end
  end

  before(:each) do
    create_models
  end

  it "Almost regular use case" do
    movables = fetch_ordered

    10.times do |time|
      puts "#{time+1} loop started"

      movables.each do |movable|
        old_position = movable.position
        new_position = movable.position + 1000/(time + 0.5)

        puts "Moving #{movable.id} movable from #{old_position} to #{new_position}"
        movable.move(new_position)
        expect(true).to be_truthy
      end

      puts "#{time+1} loop finished"
    end
  end

  it "Edge case" do
    movables = [DESCMovable.first, DESCMovable.last]

    movables.each do |movable|
      movable.move(1)
    end

    500.times do |time|
      puts "#{time+1} loop started"

      movables.each_with_index do |movable, index|
        other = movables[(index - 1) *-1]
        old_position = movable.position
        new_position = (movable.position + other.reload.position)/2

        puts "Moving #{movable.id} movable from #{old_position} to #{new_position}"
        movable.move(new_position)
        expect(true).to be_truthy
      end

      puts "#{time+1} loop finished"
    end
  end
end
