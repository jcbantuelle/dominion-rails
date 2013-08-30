require 'spec_helper'

describe 'Spoils' do
  let(:card_name) { 'spoils' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'
    it 'gives +$3' do
      spoils_pile = GameCard.create game: @game, card: @card, remaining: 9
      @subject.play_card
      @turn.reload
      expect(@turn.phase).to eq('treasure')
      expect(@turn.coins).to eq(3)
    end

    it 'returns to the spoils pile' do
      spoils_pile = GameCard.create game: @game, card: @card, remaining: 9
      @subject.play_card
      spoils_pile.reload
      expect(@game_player.in_play.count).to eq(0)
      expect(spoils_pile.remaining).to eq(10)
    end

    it 'does not count towards the supply' do
      spoils_pile = GameCard.create game: @game, card: @card, remaining: 0
      expect(@game.game_cards.empty_piles.count).to eq(0)
    end
  end

  describe '#buy' do
    include_context 'gain card'

    it 'can not be purchased' do
      GameCard.create game: @game, card: @card, remaining: 10
      expect(@subject.valid_buy?).to eq(false)
    end
  end
end
