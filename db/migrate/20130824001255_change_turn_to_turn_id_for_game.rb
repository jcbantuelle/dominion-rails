class ChangeTurnToTurnIdForGame < ActiveRecord::Migration
  def change
    rename_column :games, :turn, :turn_id
  end
end
