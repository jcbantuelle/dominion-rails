require 'spec_helper'

describe 'Grand Market' do
  let(:card_name) { 'grand_market' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'

    it 'gives +$2, +1 card, +1 action, +1 buy' do
      PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
      @subject.play_card
      @turn.reload
      expect(@turn.buys).to eq(2)
      expect(@turn.coins).to eq(2)
      expect(@turn.actions).to eq(1)
      expect(@game_player.hand.count).to eq(1)
    end
  end

  describe '#buy' do
    include_context 'gain card'

    before(:each) do
      grand_market = Card.create name: 'grand_market'
      GameCard.create game: @game, card: grand_market, remaining: 10
      @copper = Card.create name: 'copper'
      @game.current_turn.update coins: 6
    end

    context 'with copper in play' do
      it 'can not be purchased' do
        PlayerCard.create game_player: @game_player, card: @copper, state: 'play'
        expect(@subject.valid_buy?).to eq(false)
      end
    end

    context 'without copper in play' do
      it 'can be purchased' do
        expect(@subject.valid_buy?).to eq(true)
      end
    end
  end
end
