require 'spec_helper'

describe 'Nomad Camp' do
  let(:card_name) { 'nomad_camp' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'

    it 'gives +$2, +1 buy' do
      @subject.play_card
      @turn.reload
      expect(@turn.buys).to eq(2)
      expect(@turn.coins).to eq(2)
    end
  end

  describe '#gain' do
    include_context 'gain card'

    it 'is placed on deck' do
      @subject.gain_card('discard')
      expect(@game_player.discard.count).to eq(0)
      expect(@game_player.deck.count).to eq(1)
    end
  end
end
