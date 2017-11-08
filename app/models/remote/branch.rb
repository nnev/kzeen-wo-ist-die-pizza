# Example: https://delivery-app.app-smart.services/api2.5/D4LQjy8fNbse392x/get-branches
class Remote::Branch
  @raw = nil
  @main = nil

  def self.raw
    @raw ||= JsonCache.get('get-branches')
  end

  def self.main
    @main ||= self.new(branch_id: Rails.application.config.shop_branch_id)
  end

  def initialize(branch_id:)
    @branch_id = branch_id
    @data = self.class.raw['d']['branches'].detect { |xx| xx['id'] == branch_id }
    raise "No data found for branch_id=#{branch_id}" unless @data
  end

  attr_reader :branch_id

  def name
    @data['name']
  end

  def phone
    @data['tel']
  end

  def categories
    ::Remote::Category.all(branch_id: @branch_id)
  end

  def address
    <<~EOF.strip
      #{@data['name']}
      #{@data['street']} #{@data['street_no']}
      #{@data['city_code']} #{@data['city']}
    EOF
  end
end
