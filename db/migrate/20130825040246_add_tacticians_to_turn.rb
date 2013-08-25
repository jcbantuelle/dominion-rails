class AddTacticiansToTurn < ActiveRecord::Migration
  def change
    add_column :turns, :tacticians, :integer, default: 0
  end
end
