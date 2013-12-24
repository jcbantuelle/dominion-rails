class AddTradeRoute < ActiveRecord::Migration
  def change
    add_column :games, :has_trade_route, :boolean, default: false
    add_column :games, :trade_route_tokens, :integer, default: 0

    add_column :game_cards, :has_trade_route_token, :boolean, default: false
  end
end
