class AddCoppersmithToTurns < ActiveRecord::Migration
  def change
    add_column :turns, :coppersmith, :integer, default: 0
  end
end
