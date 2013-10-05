class AddRoguesToTurns < ActiveRecord::Migration
  def change
    add_column :turns, :rogues, :integer, default: 0
  end
end
