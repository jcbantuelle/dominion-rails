class AddDefaultsToTurn < ActiveRecord::Migration
  def change
    change_column :turns, :actions, :integer, default: 1
    change_column :turns, :buys, :integer, default: 1
    change_column :turns, :coins, :integer, default: 0
    change_column :turns, :phase, :string, default: 'action'
    change_column :turns, :potions, :integer, default: 0
  end
end
