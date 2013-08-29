require 'spec_helper'

describe 'Sea Hag' do
  let(:card_name) { 'sea_hag' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'
    include_context 'other players'

    before(:each) do
      curse = Card.find(Card.create(name: 'curse'))
      GameCard.create game: @game, card: curse, remaining: 10
    end

    it 'discards the top card of each other player deck and replaces with a curse' do
      @other_players.each do |player|
        PlayerCard.create game_player: player, card: @card, state: 'deck'
      end
      @subject.play_card
      @other_players.each do |player|
        expect(player.deck.count).to eq(1)
        expect(player.discard.count).to eq(1)
      end
    end

  end
end
