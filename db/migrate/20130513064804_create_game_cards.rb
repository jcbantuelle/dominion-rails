class CreateGameCards < ActiveRecord::Migration
  def change
    create_table :game_cards do |t|
      t.references :game, index: true
      t.references :card, index: true
      t.integer :remaining

      t.timestamps
    end
  end
end
