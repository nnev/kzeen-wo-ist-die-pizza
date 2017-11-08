# Examples:
# https://delivery-app.app-smart.services/api2.5/D4LQjy8fNbse392x/get-categories/1184
# https://delivery-app.app-smart.services/api2.5/D4LQjy8fNbse392x/get-products-of-category/1184/20138

class Remote::Category
  @raw = Concurrent::Map.new

  def self.raw(branch_id:)
    # note: we don't care about double-reads on race-conditions
    @raw.fetch_or_store(branch_id) do
      JsonCache.get('get-categories/' + branch_id.to_s)
    end
  end

  def self.all(branch_id:)
    raw(branch_id: branch_id)['d'].pluck('id').map do |xx|
      new(branch_id: branch_id, category_id: xx)
    end
  end

  def initialize(branch_id:, category_id:)
    @branch_id = branch_id
    @category_id = category_id
    @data = self.class.raw(branch_id: branch_id)['d'].detect { |xx| xx['id'] == category_id }
  end

  def products
    con_map = Remote::Category.instance_variable_get(:@raw)
    # note: we don't care about double-reads on race-conditions
    json = con_map.fetch_or_store("bra#{@branch_id}_cat#{@category_id}") do
      JsonCache.get("get-products-of-category/#{@branch_id}/#{@category_id}")
    end

    json['d'].pluck('id').map do |xx|
      ::Remote::Product.new(branch_id: @branch_id, product_id: xx)
    end
  end

  attr_reader :category_id

  def picture_url
    @data['picurl']&.sub('http://', 'https://')
  end

  def description
    @data['description']
  end

  def name
    @data['name']
  end
end
