class ToolController < ApplicationController
  def set_nick
    cookies.permanent[COOKIE_NICK] = params[:nick]
    target = request.referer || @basket || root_path
    redirect_to target
  end

  def toggle_admin
    cookies.permanent[COOKIE_ADMIN] = !@is_admin
    render json: { reload: true }
  end
end
