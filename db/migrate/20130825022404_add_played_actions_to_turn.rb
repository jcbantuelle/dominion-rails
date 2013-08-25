class AddPlayedActionsToTurn < ActiveRecord::Migration
  def change
    add_column :turns, :played_actions, :integer, default: 0
  end
end
