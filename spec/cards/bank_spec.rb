require 'spec_helper'

describe 'Bank' do
  let(:card_name) { 'bank' }

  include_context 'play card'

  describe '#play' do
    it 'adds $1 per treasure in play' do
      2.times do
        PlayerCard.create game_player: @game_player, card: @card, state: 'play'
      end
      @subject.play_card
      @turn.reload
      expect(@turn.phase).to eq('treasure')
      expect(@turn.coins).to eq(3)
    end
  end
end
