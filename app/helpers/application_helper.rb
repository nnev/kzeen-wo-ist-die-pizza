module ApplicationHelper
  def €(price)
    number_to_currency(price, unit: '€', separator: ',', delimiter: '', format: '%n %u')
  end

  def tips?
    Rails.application.config.tip_percent > 0
  end

  def edits_other_order?
    defined?(@order) && @order && @order.nick != @nick && @nick.present?
  end

  def vanity_order_path
    if edits_other_order?
      order_path(order_id: @order.id)
    elsif Basket.current.id == @basket&.id
      my_order_path
    elsif @order
      order_path(order_id: @order.id)
    else # not quite correct, but can only add orders to current basket
      vanity_basket_path
    end
  end

  def vanity_basket_path
    return root_path if @basket.nil? || Basket.current.id == @basket.id
    basket_path(@basket)
  end
end
