class AddRoyalSealToTurn < ActiveRecord::Migration
  def change
    add_column :turns, :royal_seal, :boolean, default: false
  end
end
