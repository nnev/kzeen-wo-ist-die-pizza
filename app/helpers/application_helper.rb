module ApplicationHelper
  def €(price)
    number_to_currency(price, unit: '€', separator: ',', delimiter: '', format: '%n %u')
  end

  def tips?
    Rails.application.config.tip_percent > 0
  end
end
