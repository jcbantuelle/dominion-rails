class Card < ActiveRecord::Base

  scope :card_type, ->(card_type) { where({card_type => true}) }
  scope :card_name, ->(card_name) { where(name: card_name) }

  after_find :load_card_module

  def self.by_name(card_name)
    card_name(card_name).first
  end

  def load_card_module
    extend name.classify.constantize
  end

  def playable?
    respond_to? :play
  end

  def treasure_card?
    type.include?(:treasure)
  end

  def action_card?
    type.include?(:action)
  end

  def type_class
    type.map(&:to_s).join(' ')
  end

  def play_log(game)
    @log_updater = LogUpdater.new game
    @log_updater.card_action(self, 'play')
  end

end
