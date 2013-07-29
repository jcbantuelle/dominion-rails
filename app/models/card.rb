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

  def render_play_card(game, player, get_text=nil, card_drawer=nil)
    locals = { game: game, player: player, card: self }
    locals[:get_text] = get_text if get_text
    locals[:card_drawer] = card_drawer if card_drawer
    render_log 'play_card', locals
  end

  def render_log(template, locals)
    Renderer.new.render "game/log/#{template}", locals
  end
end
