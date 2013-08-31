class CreateTurnActions < ActiveRecord::Migration
  def change
    create_table :turn_actions do |t|
      t.boolean :finished, default: false
      t.text :response
      t.text :sent_json
      t.references :game, index: true
      t.references :game_player, index: true
    end
  end
end
