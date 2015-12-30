class AddPosition2ToMovables < ActiveRecord::Migration
  def change
    add_column :movables, :position_2, :float, default: 0
  end
end
