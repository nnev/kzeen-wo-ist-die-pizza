class BasketController < ApplicationController
  before_action do
    @basket = Basket.find_by(id: params[:id]) || Basket.current_or_create
    @order = @basket.orders.with_items.where(nick: @nick).first
  end

  before_action :require_admin, except: [:show, :delivery_arrived]

  def show
  end

  def toggle_cancelled
    if not @basket.toggle(:cancelled).save(validate: false)
      flash[:error] = t 'toggle_failed'
    elsif @basket.cancelled?
      flash[:warn] = t 'basket.controller.group_order.cancelled'
    else
      flash[:success] = t 'basket.controller.group_order.reenabled'
    end
    redirect_to vanity_basket_path
  end

  def submit
    # TODO: implement me
    @basket.update!(submitted_at: Time.now)
    redirect_to vanity_basket_path
  end

  def unsubmit
    @basket.update_attribute(:submitted_at, nil)
    flash[:info] = t 'basket.controller.reopened'
    redirect_to vanity_basket_path
  end

  def delivery_arrived
    begin
      @basket.update_attribute(:arrived_at, Time.parse(params[:arrived_at]))
    rescue ArgumentError, TypeError
      @basket.update_attribute(:arrived_at, Time.now)
      flash[:error] = t 'basket.controller.invalid_time'
    end
    redirect_to vanity_basket_path
  end

  def pdf
    @static = Rails.application.config.x.pdf
    path = @static[:save_path]
      .sub('{timestamp}', Time.now.to_i.to_s)
      .sub('{basket_id}', @basket.id.to_s)
      .sub('{shop_fax}', Rails.application.config.shop_fax)
    fn = File.basename(path)

    response.headers['Content-Disposition'] = %(INLINE; FILENAME="#{fn}")
    response.headers['Content-Type'] = 'application/pdf'
    render 'fax.pdf'
  end

  private

  def require_admin
    return if @is_admin
    flash[:error] = t 'basket.controller.not_admin'
    redirect_to vanity_basket_path
  end
end
