# Examples:
# Extra ingredients:
# https://delivery-app.app-smart.services/api2.5/D4LQjy8fNbse392x/get-single-product/1184/184488
# Basic ingredients:
# https://delivery-app.app-smart.services/api2.5/D4LQjy8fNbse392x/get-single-product/1184/184470
# Weird menu:
# https://delivery-app.app-smart.services/api2.5/D4LQjy8fNbse392x/get-single-product/1184/184465

class Remote::Product
  @raw = Concurrent::Map.new

  def self.raw(branch_id:, product_id:)
    # note: we don't care about double-reads on race-conditions
    @raw.fetch_or_store("bra#{branch_id}_pro#{product_id}") do
      JsonCache.get("get-single-product/#{branch_id}/#{product_id}")
    end.freeze
  end

  def raw
    self.class.raw(branch_id: @branch_id, product_id: @product_id).freeze
  end

  def initialize(branch_id:, product_id:)
    @branch_id = branch_id
    @product_id = product_id
  end

  attr_reader :product_id

  def valid?
    name.present? && data['sizes'].present? && min_price.present? && sizes.present?
  end

  def description
    data['description'].freeze
  end

  def name
    data['name'].presence&.freeze || "branch_id=#{@branch_id} product_id=#{@product_id} #{I18n.t('outdated_data')}"
  end

  def min_price
    # Note: lowest_price* fields given on the root level refer to either the last
    # or the maximum price. So instead we have to go through the sizes.
    # data['lowest_price_delivery'] || data['lowest_price'] || data['lowest_price_selfcollect']
    data['sizes'].values.pluck('delivery_price').min.freeze
  end

  def sizes
    data['sizes'].values.map do |xx|
      price = xx['delivery_price'] || xx['self_collector_price']
      { size_id: xx['pos'], name: xx['name'], price: price }
    end.freeze
  rescue => e
    self.print_invalid_json_error(e)
    []
  end

  def named_size(selection)
    return nil if self.sizes.size <= 1
    self.sizes.detect { |xx| xx[:size_id] == selection[:size] }[:name].freeze
  end

  def basic_ingredients # TODO: fugly
    data['basic_ingredients_groups'].map do |group_id, group|
      if group['max_quan'] != group['free_quan']
        # Note: we ignore min_quan. So does the official web, by the way :)
        raise 'Different amounts of basic ingredients voodoo is not implemented'
      end

      ingreds = group['ingredients'].map do |ingred_id, ingred|
        if ingred['price_diff'].values.pluck('price').any? { |p| p != 0.0 }
          raise 'Cannot handle base ingredients that cost money'
        end

        details = data['ingredient_basics_with_details'][ingred_id] || {}
        desc = desc_if_different(details['description'], ingred['name'])
        {
          ingred_id:   ingred_id.to_i,
          name:        ingred['name'],
          description: desc,
        }
      end

      {
        group_id:      group_id.to_i,
        ingreds:       sort_by_name!(ingreds),
        allowed_count: group['free_quan'],
        description:   group['description']
      }
    end.freeze
  end

  def basic_ingredient_ids
    data['basic_ingredients_groups'].keys.map(&:to_i)
  end

  def named_basic_ingredients(selection)
    selection[:basic_ingred].map do |group_id, ingred_ids|
      ingreds = data['basic_ingredients_groups'][group_id.to_s]['ingredients']
      ingred_ids.map do |ingred_id|
        ing = ingreds[ingred_id.to_s]
        ing ? ing['name'] : "ingredient_id=#{ingred_id} #{I18n.t('outdated_data')}"
      end
    end
  end

  def extra_ingredients
    ingred = data['ingredient_extras_with_details'].map do |ingred_id, xx|
      {
        ingred_id: ingred_id.to_i,
        name:      xx['name'],
        details:   desc_if_different(xx['description'], xx['name']),
        prices:    Hash[xx['price_of_ingredient_for_size'].map do |size_id, value| # TODO: fugly
          [size_id, value['p']]
        end]
      }
    end
    sort_by_name!(ingred).freeze
  end

  def extra_ingredient_ids
    return [] unless data['ingredient_extras_with_details'].is_a?(Hash)
    data['ingredient_extras_with_details'].keys.map(&:to_i).freeze
  end

  def named_extra_ingredients(selection)
    xx = selection[:extra_ingred].map(&:to_s)
    data['ingredient_extras_with_details'].slice(*xx).values.pluck('name').freeze
  end

  def price(selection)
    size = self.sizes.detect { |xx| xx[:size_id] == selection[:size] }
    return 0.0 if size.nil?

    base = size[:price]

    selected_extras = selection[:extra_ingred].map(&:to_s)
    return base if selected_extras.empty?

    extras = data['ingredient_extras_with_details'].slice(*selected_extras).values
    cost = extras.pluck('price_of_ingredient_for_size').pluck(selection[:size].to_s).pluck('p')

    base + cost.sum
  end

  private

  def print_invalid_json_error(error)
    Rails.logger.error <<~ERROR
      invalid product: branch_id=#{@branch_id} product_id=#{@product_id}
      Does this product still exist?
      Error
        #{error.to_s}

      Backtrace
        #{error.backtrace.join("\n  ")}

      JSON data for this product
        #{JSON.dump(data)}
    ERROR
  end

  def data
    @data ||= raw['d'].freeze
  end

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
