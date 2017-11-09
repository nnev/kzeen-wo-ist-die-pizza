class OrderController < ApplicationController
  before_action do
    @basket = Basket.current_or_create
  end

  before_action :find_or_init_order

  def show
  end

  def item_create
    @order.add_item(permitted_params)
    if @order.save
      show_basket
    else
      render status: :bad_request, json: @order.errors
    end
  end

  def item_destroy

  end

  def item_update

  end

  def show_basket
    render partial: 'show_basket'
  end

  private

  def find_or_init_order
    @order = Order.find_or_initialize_by(nick: @nick, basket: @basket)
  end

  def permitted_params
    params.permit(:product_id, :size, extra_ingred: [], basic_ingred: {})
  end
end
