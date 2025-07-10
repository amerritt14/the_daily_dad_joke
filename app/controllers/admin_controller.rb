class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin

  def jokes
    @pending_jokes = Joke.pending.order(created_at: :desc)
    @approved_jokes = Joke.approved.order(created_at: :desc).limit(10)
    @rejected_jokes = Joke.rejected.order(created_at: :desc).limit(10)
  end

  def approve_joke
    joke = Joke.find(params[:id])
    joke.update!(status: 'approved')
    redirect_to admin_jokes_path, notice: 'Joke approved!'
  end

  def reject_joke
    joke = Joke.find(params[:id])
    joke.update!(status: 'rejected')
    redirect_to admin_jokes_path, notice: 'Joke rejected!'
  end

  private

  def ensure_admin
    # For now, any authenticated user is admin
    # You could add an admin field to users table later
    redirect_to root_path unless user_signed_in?
  end
end
