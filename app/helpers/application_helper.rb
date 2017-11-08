module ApplicationHelper
  def €(price)
    number_to_currency(price, unit: '€', separator: ',', delimiter: '', format: '%n %u')
  end
end
