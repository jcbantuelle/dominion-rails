class Turn < ActiveRecord::Base
  belongs_to :game
  belongs_to :game_player

  scope :ordered, ->{ order 'turn DESC' }

  def action_phase?
    phase == 'action'
  end

  def buy_phase
    update_attribute :phase, 'buy'
  end

  def buy_phase?
    phase == 'buy'
  end

  def treasure_phase
    update_attribute :phase, 'treasure'
  end

  def treasure_phase?
    phase == 'treasure'
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

  def add_potions(amount)
    update_attribute :potions, potions + amount
  end

  def add_played_action
    update_attribute :played_actions, played_actions + 1
  end

  def add_coppersmith
    update_attribute :coppersmith, coppersmith + 1
  end

  def add_haggler
    update_attribute :hagglers, hagglers + 1
  end

  def add_scheme
    update_attribute :schemes, schemes + 1
  end

  def add_minion
    update_attribute :minions, minions + 1
  end

  def add_fools_gold
    update_attribute :fools_gold, fools_gold + 1
  end

  def add_mercenary
    update_attribute :mercenaries, mercenaries + 1
  end

  def add_tactician
    update_attribute :tacticians, tacticians + 1
  end

  def add_hoard
    update_attribute :hoards, hoards + 1
  end

  def add_talisman
    update_attribute :talismans, talismans + 1
  end

  def add_rogue
    update_attribute :rogues, rogues + 1
  end

  def remove_tactician
    update_attribute :tacticians, tacticians - 1
  end

  def remove_minion
    update_attribute :minions, minions - 1
  end

  def remove_scheme
    update_attribute :schemes, schemes - 1
  end

  def remove_mercenary
    update_attribute :mercenaries, mercenaries - 1
  end

  def remove_rogue
    update_attribute :rogues, rogues - 1
  end

  def add_lighthouse
    update_attribute :lighthouse, true
  end

  def add_crossroad
    update_attribute :crossroads, crossroads + 1
  end

  def add_outpost
    update_attribute :outpost, true
  end

  def add_global_discount(amount)
    update_attribute :global_discount, global_discount + amount
  end

  def add_action_discount(amount)
    update_attribute :action_discount, action_discount + amount
  end

  def add_contraband(card_id)
    new_contraband = contraband.nil? ? card_id : "#{contraband} #{card_id}"
    update_attribute :contraband, new_contraband
  end

  def buy_card(cost)
    buy_phase
    turn_attributes = {
      buys: (buys - 1),
      coins: (coins - cost[:coin]),
      bought_cards: (bought_cards + 1)
    }
    turn_attributes[:potions] = (potions - cost[:potion]) if cost[:potion].present?
    update turn_attributes
  end
end
