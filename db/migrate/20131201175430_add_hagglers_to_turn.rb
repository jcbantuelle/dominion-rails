class AddHagglersToTurn < ActiveRecord::Migration
  def change
    add_column :turns, :hagglers, :integer, default: 0
  end
end
