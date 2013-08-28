require 'spec_helper'

describe 'Monument' do
  let(:card_name) { 'monument' }

  include_context 'play card'

  describe '#play' do
    it 'updates the game state' do
      @subject.play_card
      @turn.reload
      @game_player.reload
      expect(@turn.coins).to eq(2)
      expect(@game_player.victory_tokens).to eq(1)
    end
  end
end
