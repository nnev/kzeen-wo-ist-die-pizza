class Remote::Product
  @raw = Concurrent::Map.new

  def self.raw(branch_id:, category_id:)
    # note: we don't care about double-reads on race-conditions
    @raw.fetch_or_store("#{branch_id}_#{category_id}") do
      JsonCache.get("get-products-of-category/#{branch_id}/#{category_id}")
    end
  end

  def raw
    self.class.raw(branch_id: @branch_id, category_id: @category_id)
  end

  def self.all(branch_id:, category_id:)
    raw(branch_id: branch_id, category_id:)['d'].pluck('id').map do |xx|
      new(branch_id: branch_id, category_id: category_id, product_id: xx)
    end
  end

  def initialize(branch_id:, category_id:, product_id:)
    @branch_id = branch_id
    @category_id = category_id
    @product_id = product_id
    @data = raw['d'].detect { |xx| xx['id'] == product_id }
  end

  def description
    @data['description']
  end

  def name
    @data['name']
  end
end
