require 'spec_helper'

describe 'Philosophers Stone' do
  let(:card_name) { 'philosophers_stone' }

  describe '#play' do
    include_context 'play card'

    it 'updates the game state' do
      8.times do
        PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
        PlayerCard.create game_player: @game_player, card: @card, state: 'discard'
      end
      @subject.play_card
      @turn.reload
      expect(@turn.phase).to eq('treasure')
      expect(@turn.coins).to eq(3)
    end
  end
end
