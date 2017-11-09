class Order < ApplicationRecord
  belongs_to :basket
  serialize :order, Array

  validates_presence_of :nick
  validates_presence_of :order
  validates_presence_of :basket_id

  validate do
    # Validate the order matches the data. Mostly against haxxors and to prevent
    # outdated saved to be added
    order.each do |item|
      prod = ::Remote::Product.new(branch_id: branch_id, product_id: item[:product_id])
      errors.add(:order, "Product=#{item[:product_id]} does not exist") if prod.name.blank?

      unknown_extra_ingred = item[:extra_ingred] - prod.extra_ingredient_ids
      errors.add(:order, "Product=#{item[:product_id]} has unknown extra ingredients: #{unknown_extra_ingred.join(', ')}") if unknown_extra_ingred.any?

      unknown_basic_ingred = item[:basic_ingred].keys - prod.basic_ingredient_ids
      errors.add(:order, "Product=#{item[:product_id]} has unknown basic ingredients: #{unknown_basic_ingred.join(', ')}") if unknown_basic_ingred.any?

      prod.basic_ingredients.each do |details|
        given = item[:basic_ingred][details[:group_id]]
        if given && given.size > details[:allowed_count]
          errors.add(:order, "Product=#{item[:product_id]} basic_ingred=#{details[:group_id]} allows up to #{details[:allowed_count]}, but #{given.size} were given")
        end
      end
    end
  end

  delegate :branch_id, to: :basket

  def add_item(data)
    new_order = {
      product_id:   data.fetch('product_id').to_i,
      size:         data.fetch('size').to_i,
      extra_ingred: data['extra_ingred']&.map(&:to_i) || [],
      basic_ingred: {}
    }
    if data['basic_ingred']
      # hash of the form {group_id => [ignred_id, ingred_id, …]}
      new_order[:basic_ingred] = Hash[data['basic_ingred'].to_h.map do |group_id, data|
        [group_id.to_i, data.values.map(&:to_i)]
      end]
    end

    self.order << new_order
  end

  def total
    order.map do |item|
      prod = ::Remote::Product.new(branch_id: branch_id, product_id: item[:product_id])
      prod.price(item)
    end.sum
  end
end
