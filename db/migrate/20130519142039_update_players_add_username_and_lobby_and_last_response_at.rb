class UpdatePlayersAddUsernameAndLobbyAndLastResponseAt < ActiveRecord::Migration
  def change
    add_column :players, :username, :string
    add_column :players, :lobby, :boolean
    add_column :players, :last_response_at, :datetime
  end
end
