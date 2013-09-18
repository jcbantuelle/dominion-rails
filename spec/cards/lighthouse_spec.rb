require 'spec_helper'

describe 'Lighthouse' do
  let(:card_name) { 'lighthouse' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'

    it 'gives +1 action and +$1' do
      @subject.play_card
      @turn.reload
      expect(@turn.actions).to eq(1)
      expect(@turn.coins).to eq(1)
    end
  end

  describe '#duration' do
    include_context 'duration'

    it 'gives +$1' do
      @subject.next_turn
      expect(@game.current_turn.coins).to eq(1)
    end
  end

  describe 'attack immunity' do
    let(:reaction_card_trigger) { Card.find(Card.create(name: 'witch').id) }
    include_context 'other players'
    include_context 'reaction'
    include_context 'urchin card'
    it 'gives immunity to attacks' do
      curse = Card.find(Card.create(name: 'curse'))
      GameCard.create game: @game, card: curse, remaining: 10
      @other_players.each do |player|
        Turn.create game_player: player, lighthouse: 1
      end
      @reaction_card_player.play_card
      @other_players.each do |player|
        expect(player.discard.count).to eq(0)
      end
    end
  end

end
