class ProductController < ApplicationController
  before_action do
    @basket = Basket.current
    @product = ::Remote::Product.new(branch_id: @basket.branch_id, product_id: params[:id])
  end

  def show
    @size = permitted_params[:size].presence&.to_i || nil
    @extra_ingred = permitted_params[:extra_ingred]&.map(&:to_i) || []
    @basic_ingred = Hash[permitted_params[:basic_ingred].to_h.map { |k, v| [k.to_i, v.map(&:to_i)] }]

    render partial: 'show'
  end

  private

  def permitted_params
    params.permit(:product_id, :size, extra_ingred: [], basic_ingred: {})
  end
end
