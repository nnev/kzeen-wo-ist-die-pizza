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
    Product.all(branch_id: @branch_id, category_id: @category_id)
  end

  def description
    @data['description']
  end

  def name
    @data['name']
  end
end
