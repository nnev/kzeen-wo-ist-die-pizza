class ProductController < ApplicationController
  before_action do
    @basket = Basket.current
    @product = ::Remote::Product.new(branch_id: @basket.branch_id, product_id: params[:id])
  end

  def show
    set_selected_item
    render partial: 'show'
  end

  private

  def set_selected_item
    @size = nil
    @basic_ingred = {}
    @extra_ingred = []

    return unless params[:select] =~ /\A\d+\z/
    selected = params[:select].to_i

    order = Order.find_by(nick: @nick, basket: @basket)
    return unless order

    items = order.order[selected]
    return unless items

    @size = items['size']
    @extra_ingred = items['extra_ingred']
    @basic_ingred = items['basic_ingred']
  end
end
