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

end
