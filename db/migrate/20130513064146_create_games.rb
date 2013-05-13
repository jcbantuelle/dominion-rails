class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :turn

      t.timestamps
    end
  end
end
