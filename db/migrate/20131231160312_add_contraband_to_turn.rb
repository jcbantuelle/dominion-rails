class AddContrabandToTurn < ActiveRecord::Migration
  def change
    add_column :turns, :contraband, :string
  end
end
