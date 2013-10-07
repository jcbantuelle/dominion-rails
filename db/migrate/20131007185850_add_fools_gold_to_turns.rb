class AddFoolsGoldToTurns < ActiveRecord::Migration
  def change
    add_column :turns, :fools_gold, :integer, default: 0
  end
end
