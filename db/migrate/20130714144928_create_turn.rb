class CreateTurn < ActiveRecord::Migration
  def change
    create_table :turns do |t|
      t.references :game, index: true
      t.references :game_player, index: true
      t.integer :actions
      t.integer :buys
      t.integer :coins
      t.integer :turn
    end
  end
end
