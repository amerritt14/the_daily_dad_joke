class JokesController < ApplicationController
  before_action :authenticate_user!

  def index
    @jokes = Joke.all
  end
end
