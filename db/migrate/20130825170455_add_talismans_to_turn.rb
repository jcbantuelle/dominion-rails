class AddTalismansToTurn < ActiveRecord::Migration
  def change
    add_column :turns, :talismans, :integer, default: 0
  end
end
