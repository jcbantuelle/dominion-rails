class AddLighthouseToTurn < ActiveRecord::Migration
  def change
    add_column :turns, :lighthouse, :boolean, default: false
  end
end
