class AddFinishedToGame < ActiveRecord::Migration
  def change
    add_column :games, :finished, :boolean
  end
end
