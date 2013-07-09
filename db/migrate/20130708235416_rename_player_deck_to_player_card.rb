class RenamePlayerDeckToPlayerCard < ActiveRecord::Migration
  def change
    rename_table :player_decks, :player_cards
  end
end
