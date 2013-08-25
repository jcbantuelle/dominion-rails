class AddActionDiscountToTurn < ActiveRecord::Migration
  def change
    add_column :turns, :action_discount, :integer, default: 0
  end
end
