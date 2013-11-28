class AddSchemesToTurn < ActiveRecord::Migration
  def change
    add_column :turns, :schemes, :integer, default: 0
  end
end
