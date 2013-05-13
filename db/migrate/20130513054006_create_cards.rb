class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :name
      t.string :set
      t.boolean :kingdom
      t.boolean :treasure
      t.boolean :victory

      t.timestamps
    end
  end
end
