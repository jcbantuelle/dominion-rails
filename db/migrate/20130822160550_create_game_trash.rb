class CreateGameTrash < ActiveRecord::Migration
  def change
    create_table :game_trashes do |t|
      t.references :game, index: true
      t.references :card, index: true
    end
  end
end
