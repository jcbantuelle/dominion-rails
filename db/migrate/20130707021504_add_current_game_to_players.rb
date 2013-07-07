class AddCurrentGameToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :current_game, :integer
  end
end
