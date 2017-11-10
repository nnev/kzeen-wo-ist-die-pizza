class OrderController < ApplicationController
  before_action do
    @basket = Basket.current_or_create
  end

  before_action :find_or_init_order
  before_action :check_permissions

  def show
  end

  def destroy
    @order.destroy!

  end

  def item_create
    @order.add_item(permitted_params)
    save_items
  end

  def item_destroy
    # special case to avoid empty orders in group basket
    if @order.order.size == 1 && params[:index].to_i == 0
      @order = find_or_init_order if @order.destroy
      show_basket
    else
      @order.destroy_item(params[:index].to_i)
      save_items
    end
  end

  def item_update
    @order.update_item(params[:index].to_i, permitted_params)
    save_items
  end

  def show_basket
    render partial: 'show_basket'
  end

  private

  def save_items
    if @order.save
      show_basket
    else
      render status: :bad_request, json: @order.errors
    end
  end

  def find_or_init_order
    @order = Order.find_or_initialize_by(nick: @nick, basket: @basket)
  end

  def permitted_params
    params.permit(:product_id, :size, extra_ingred: [], basic_ingred: {})
  end

  def check_permissions
    return if @is_admin
    return if @order.new_record?
    return if @order.nick == @nick

    flash[:warn] = I18n.t('order.controller.admin_required')
    redirect_to :root
  end
end
