require 'spec_helper'

describe 'Witch' do
  let(:card_name) { 'witch' }
  include_context 'setup'
  include_context 'urchin card'


  describe '#play' do
    include_context 'play card'

    before(:each) do
      curse = Card.find(Card.create(name: 'curse'))
      GameCard.create game: @game, card: curse, remaining: 10
    end

    it 'gives +2 cards' do
      3.times do
        PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
      end
      @subject.play_card
      @turn.reload
      expect(@game_player.hand.count).to eq(2)
    end

    include_context 'other players'

    it 'gives a curse to each other player' do
      @subject.play_card
      @other_players.each do |player|
        expect(player.discard.count).to eq(1)
      end
    end

  end
end
