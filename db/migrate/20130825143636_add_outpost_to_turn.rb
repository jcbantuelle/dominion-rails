class AddOutpostToTurn < ActiveRecord::Migration
  def change
    add_column :turns, :outpost, :boolean, default: 0
  end
end
