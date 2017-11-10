class MiscController < ApplicationController
  def set_nick
    # prefer case of existing nick
    Basket.first.orders.pluck(:nick).each do |existing_nick|
      if existing_nick.downcase == params[:nick].downcase
        params[:nick] = existing_nick
        break
      end
    end

    cookies.permanent[COOKIE_NICK] = params[:nick]

    redirect_back(fallback_location: root_path)
  end

  def toggle_admin
    cookies.permanent[COOKIE_ADMIN] = !@is_admin
    redirect_back(fallback_location: root_path)
  end

  def privacy
  end
end
