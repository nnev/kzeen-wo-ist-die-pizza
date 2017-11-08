class ProductController < ApplicationController
  before_action do
    @basket = Basket.current
    @product = ::Remote::Product.new(branch_id: @basket.branch_id, product_id: params[:id])
  end

  def show
    render partial: 'show'
  end
end
