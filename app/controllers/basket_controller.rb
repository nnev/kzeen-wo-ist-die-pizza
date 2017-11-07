class BasketController < ApplicationController
  before_action do
    @basket = Basket.current_or_create
    @order = @basket.orders.where(nick: @nick).first
  end

  def show

  end


end
