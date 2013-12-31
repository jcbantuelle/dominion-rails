class AddAffectedIdToTurnActions < ActiveRecord::Migration
  def change
    add_column :turn_actions, :affected_id, :integer
  end
end
