class AddEmbargosToGameCards < ActiveRecord::Migration
  def change
    add_column :game_cards, :embargos, :integer, default: 0
  end
end
