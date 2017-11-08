# Examples:
# Extra ingredients:
# https://delivery-app.app-smart.services/api2.5/D4LQjy8fNbse392x/get-single-product/1184/184488
# Basic ingredients:
# https://delivery-app.app-smart.services/api2.5/D4LQjy8fNbse392x/get-single-product/1184/184470

class Remote::Product
  @raw = Concurrent::Map.new

  def self.raw(branch_id:, product_id:)
    # note: we don't care about double-reads on race-conditions
    @raw.fetch_or_store("bra#{branch_id}_pro#{product_id}") do
      JsonCache.get("get-single-product/#{branch_id}/#{product_id}")
    end
  end

  def raw
    self.class.raw(branch_id: @branch_id, product_id: @product_id)
  end

  def initialize(branch_id:, product_id:)
    @branch_id = branch_id
    @product_id = product_id
    @data = raw['d']

    # TODO:
    # basic_ingredients_groups / ingredient_basics_with_details
    # are both needed?
  end

  attr_reader :product_id

  def description
    @data['description']
  end

  def name
    @data['name']
  end

  def price
    # Note: lowest_price* fields given on the root level refer to either the last
    # or the maximum price. So instead we have to go through the sizes.
    # @data['lowest_price_delivery'] || @data['lowest_price'] || @data['lowest_price_selfcollect']
    @data['sizes'].values.pluck('delivery_price').min
  end

  def sizes
    @data['sizes'].values.map do |xx|
      price = xx['delivery_price'] || xx['self_collector_price']
      { size_id: xx['pos'], name: xx['name'], price: price }
    end
  end

  def extra_ingredients
    ingred = @data['ingredient_extras_with_details'].values
    ingred.sort_by! { |xx| remove_lowercase_words(xx['name']) }

    ingred.map do |xx|
      {
        name:    xx['name'],
        details: xx['description'] == xx['name'] ? nil : xx['description'],
        prices:  Hash[xx['price_of_ingredient_for_size'].map do |size_id, value|
          [size_id, value['p']]
        end]
      }
    end
  end

  private

  def remove_lowercase_words(string)
    string.scan(/\p{Upper}[^\s]+/).join(' ')
  end
end
