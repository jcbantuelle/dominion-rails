class AddGlobalDiscountToTurns < ActiveRecord::Migration
  def change
    add_column :turns, :global_discount, :integer, default: 0
  end
end
