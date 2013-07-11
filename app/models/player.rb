class Player < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :game, foreign_key: 'current_game'

  Warden::Manager.before_logout do |record, warden, options|
    record.update_attribute :online, false
  end

  has_many :game_players

  scope :in_lobby, ->{ where(lobby: true) }
  scope :in_game, ->{ where.not(current_game: nil) }
  scope :online, ->{ where(online: true) }
  scope :inactive, ->{ where('last_response_at < ?', 10.minutes.ago) }
end
