class CardCostCalculater

  def initialize(game, card)
    @game = game
    @card = card
  end

  def cost
    calculated_coin = base_coin - coin_discount
    calculated_coin = 0 if calculated_coin < 0

    cost_values = [[:coin, calculated_coin]]
    cost_values << [:potion, base_cost[:potion]] unless base_cost[:potion].nil?

    Hash[cost_values]
  end

  private

  def base_cost
    @base_cost ||= @card.cost @game
  end

  def base_coin
    @base_coin ||= base_cost[:coin]
  end

  def coin_discount
    @coin_discount ||= calculate_coin_discount
  end

  def calculate_coin_discount
    discount = 0
    unless @game.current_turn.nil?
      discount += global_discount
      discount += action_discount if @card.action_card?
    end
    discount
  end

  def global_discount
    @game.current_turn.global_discount
  end

  def action_discount
    @game.current_turn.action_discount
  end

end
