class Player < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :game_players

  scope :in_lobby, ->{ where(lobby: true) }
  scope :online, ->{ where('last_response_at > ?', 10.minutes.ago) }
end
