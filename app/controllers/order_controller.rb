class OrderController < ApplicationController
  before_action do
    @basket = Basket.current_or_create
  end

  def new

  end
end
