class AddHoardsToTurn < ActiveRecord::Migration
  def change
    add_column :turns, :hoards, :integer, default: 0
  end
end
