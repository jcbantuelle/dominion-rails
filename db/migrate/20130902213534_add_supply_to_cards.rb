class AddSupplyToCards < ActiveRecord::Migration
  def change
    add_column :cards, :supply, :boolean, default: 1
  end
end
