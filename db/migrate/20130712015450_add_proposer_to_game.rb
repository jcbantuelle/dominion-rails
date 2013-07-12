class AddProposerToGame < ActiveRecord::Migration
  def change
    add_column :games, :proposer_id, :integer
  end
end
