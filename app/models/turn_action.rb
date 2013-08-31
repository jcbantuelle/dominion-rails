class TurnAction < ActiveRecord::Base
  belongs_to :game
  belongs_to :game_player

  def self.find_uncached(action_id)
    uncached do
      find(action_id) if exists?(action_id)
    end
  end
end
