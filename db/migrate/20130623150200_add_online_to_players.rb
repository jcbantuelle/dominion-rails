class AddOnlineToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :online, :boolean, default: false
  end
end
