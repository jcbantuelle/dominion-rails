class CreatePlayerDecks < ActiveRecord::Migration
  def change
    create_table :player_decks do |t|
      t.references :game_player, index: true
      t.references :card, index: true
      t.integer :card_order

      t.timestamps
    end
  end
end
