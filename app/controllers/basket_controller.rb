class BasketController < ApplicationController
  before_action do
    @basket = Basket.current_or_create
    @order = @basket.orders.with_items.where(nick: @nick).first
  end

  def show

  end


end
