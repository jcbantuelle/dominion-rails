class LobbyController < ApplicationController
  include Tubesock::Hijack

  before_filter :authenticate_player!

  def update
    set_lobby
    hijack do |tubesock|
      @@lobby[current_player.id] = tubesock
      tubesock.onopen do
        refresh_lobby
      end
    end
  end

end
