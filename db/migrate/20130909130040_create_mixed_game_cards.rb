class CreateMixedGameCards < ActiveRecord::Migration
  def change
    create_table :mixed_game_cards do |t|
      t.references :game_card, index: true
      t.references :card, index: true
      t.integer :card_order
      t.string :card_type
    end
  end
end
