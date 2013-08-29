require 'spec_helper'

describe 'Poor House' do
  let(:card_name) { 'poor_house' }
  include_context 'setup'

  describe '#play' do

    include_context 'play card'

    it 'gives +$4 minus $1 per treasure card in hand' do
      treasure = Card.find(Card.create(name: 'copper'))
      2.times do
        PlayerCard.create game_player: @game_player, card: treasure, state: 'hand'
      end
      @subject.play_card
      @turn.reload
      expect(@turn.coins).to eq(2)
    end
  end
end
