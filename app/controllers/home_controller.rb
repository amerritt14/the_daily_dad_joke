class HomeController < ApplicationController
  def index
    if user_signed_in?
      redirect_to jokes_path
    else
      redirect_to new_joke_path
    end
  end
end
