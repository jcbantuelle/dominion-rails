class AddCrossroadsToTurn < ActiveRecord::Migration
  def change
    add_column :turns, :crossroads, :integer, default: 0
  end
end
