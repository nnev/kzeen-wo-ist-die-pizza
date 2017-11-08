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

  def basic_ingredients # TODO: fugly
    @data['basic_ingredients_groups'].map do |group_id, group|
      if group['max_quan'] != group['free_quan']
        # Note: we ignore min_quan. Neither does the official web, by the way :)
        raise 'Different amounts of basic ingredients voodoo is not implemented'
      end

      ingreds = group['ingredients'].map do |ingred_id, ingred|
        if ingred['price_diff'].values.pluck('price').any? { |p| p != 0.0 }
          raise 'Cannot handle base ingredients that cost money'
        end

        details = @data['ingredient_basics_with_details'][ingred_id] || {}
        desc = desc_if_different(details['description'], ingred['name'])
        {
          ingred_id:   ingred_id,
          name:        ingred['name'],
          description: desc,
        }
      end

      {
        group_id:      group_id,
        ingreds:       sort_by_name!(ingreds),
        allowed_count: group['free_quan'],
        description:   group['description']
      }
    end
  end

  def extra_ingredients
    ingred = sort_by_name!(@data['ingredient_extras_with_details'].values)
    ingred.map do |xx|
      {
        name:    xx['name'],
        details: desc_if_different(xx['description'], xx['name']),
        prices:  Hash[xx['price_of_ingredient_for_size'].map do |size_id, value| # TODO: fugly
          [size_id, value['p']]
        end]
      }
    end
  end

  private

  def sort_by_name!(arr)
    arr.sort_by! { |xx| remove_lowercase_words(xx['name'] || xx[:name]) }
    arr
  end

  def remove_lowercase_words(string)
    string.scan(/\p{Upper}[^\s]+/).join(' ')
  end

  def desc_if_different(desc, name)
    desc == name ? nil : desc
  end
end
