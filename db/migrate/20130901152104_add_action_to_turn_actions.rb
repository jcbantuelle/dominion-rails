class AddActionToTurnActions < ActiveRecord::Migration
  def change
    add_column :turn_actions, :action, :string
  end
end
