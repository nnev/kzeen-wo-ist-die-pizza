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
end
