class Turn < ActiveRecord::Base
  belongs_to :game
  belongs_to :game_player

  scope :ordered, ->{ order 'turn DESC' }

  def buy_phase
    update_attribute :phase, 'buy'
  end

  def play_action
    update_attribute :actions, actions - 1
  end

  def add_coins(amount)
    update_attribute :coins, coins + amount
  end

  def add_actions(amount)
    update_attribute :actions, actions + amount
  end

  def add_buys(amount)
    update_attribute :buys, buys + amount
  end

  def buy_card(cost)
    buy_phase
    update_attribute :buys, buys - 1
    update_attribute :coins, coins - cost[:coin]
  end
end
