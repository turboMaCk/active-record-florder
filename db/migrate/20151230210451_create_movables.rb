class CreateMovables < ActiveRecord::Migration
  def change
    create_table(:movables) do |t|
      t.references :owner
      t.float :position, default: 0
    end
  end
end
