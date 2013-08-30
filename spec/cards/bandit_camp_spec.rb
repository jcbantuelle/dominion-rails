require 'spec_helper'

describe 'Bandit Camp' do
  let(:card_name) { 'bandit_camp' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'

    it 'gives +1 card, +2 actions, and gains a spoils' do
      spoils = Card.find(Card.create(name: 'spoils'))
      GameCard.create game: @game, card: spoils, remaining: 10
      PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
      @subject.play_card
      @turn.reload
      expect(@turn.actions).to eq(2)
      expect(@game_player.hand.count).to eq(1)
      expect(@game_player.discard.count).to eq(1)
    end
  end
end
