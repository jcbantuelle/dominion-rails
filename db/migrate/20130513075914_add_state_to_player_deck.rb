class AddStateToPlayerDeck < ActiveRecord::Migration
  def change
    add_column :player_decks, :state, :string
  end
end
