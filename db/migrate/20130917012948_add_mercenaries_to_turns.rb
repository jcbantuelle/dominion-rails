class AddMercenariesToTurns < ActiveRecord::Migration
  def change
    add_column :turns, :mercenaries, :integer, default: 0
  end
end
