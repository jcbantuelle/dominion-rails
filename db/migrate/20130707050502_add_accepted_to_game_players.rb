class AddAcceptedToGamePlayers < ActiveRecord::Migration
  def change
    add_column :game_players, :accepted, :boolean, default: false
  end
end
