class AddPotionToTurns < ActiveRecord::Migration
  def change
    add_column :turns, :potions, :integer
  end
end
