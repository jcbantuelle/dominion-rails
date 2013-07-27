class AddPhaseToTurn < ActiveRecord::Migration
  def change
    add_column :turns, :phase, :string
  end
end
