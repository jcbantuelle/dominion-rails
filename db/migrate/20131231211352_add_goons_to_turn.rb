class AddGoonsToTurn < ActiveRecord::Migration
  def change
    add_column :turns, :goons, :integer, default: 0
  end
end
