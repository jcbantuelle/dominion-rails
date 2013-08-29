require 'spec_helper'

describe 'Vagrant' do
  let(:card_name) { 'vagrant' }
  include_context 'setup'

  describe '#play' do

    include_context 'play card'

    before(:each) do
      PlayerCard.create game_player: @game_player, card: @card, state: 'deck', card_order: 1
    end

    it 'gives +1 card, +1 action' do
      @subject.play_card
      @turn.reload
      expect(@turn.actions).to eq(1)
      expect(@game_player.hand.count).to eq(1)
    end

    context 'with curse on top of deck' do
      it 'puts the card in hand' do
        curse = Card.find(Card.create(name: 'curse'))
        PlayerCard.create game_player: @game_player, card: curse, state: 'deck', card_order: 2
        @subject.play_card
        expect(@game_player.hand.count).to eq(2)
        expect(@game_player.deck.count).to eq(0)
        expect(@game_player.discard.count).to eq(0)
      end
    end

    context 'with victory card on top of deck' do
      it 'puts the card in hand' do
        estate = Card.find(Card.create(name: 'estate'))
        PlayerCard.create game_player: @game_player, card: estate, state: 'deck', card_order: 2
        @subject.play_card
        expect(@game_player.hand.count).to eq(2)
        expect(@game_player.deck.count).to eq(0)
        expect(@game_player.discard.count).to eq(0)
      end
    end

    context 'without curse or victory card on top of deck' do
      it 'replaces the card' do
        PlayerCard.create game_player: @game_player, card: @card, state: 'deck', card_order: 2
        @subject.play_card
        expect(@game_player.hand.count).to eq(1)
        expect(@game_player.deck.count).to eq(1)
        expect(@game_player.discard.count).to eq(0)
      end
    end
  end
end
