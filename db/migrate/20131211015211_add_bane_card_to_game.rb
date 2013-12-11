class AddBaneCardToGame < ActiveRecord::Migration
  def change
    add_column :games, :bane_card, :string
  end
end
