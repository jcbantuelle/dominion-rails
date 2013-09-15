class AddBoughtCardsToTurns < ActiveRecord::Migration
  def change
    add_column :turns, :bought_cards, :integer, default: 0
  end
end
