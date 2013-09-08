class AddMinionsToTurns < ActiveRecord::Migration
  def change
    add_column :turns, :minions, :integer, default: 0
  end
end
