class JokesController < ApplicationController
  include RateLimiting
  
  before_action :authenticate_user!, only: [:index, :update]
  before_action :rate_limit_submission, only: [:create]
  before_action :set_joke, only: [:update]
  layout "public", only: [:new, :create]

  def index
    # Admin view - shows all jokes with status for moderation
    # Order by status: pending first, approved middle, rejected last, then by creation date
    @jokes = Joke.all.order(
      Arel.sql("CASE WHEN status = 'pending' THEN 0 WHEN status = 'approved' THEN 1 WHEN status = 'rejected' THEN 2 END"),
      created_at: :desc
    )
  end

  def new
    @joke = Joke.new
  end

  def create
    # Check honeypot field (should be empty)
    if params[:joke][:website].present?
      redirect_to new_joke_path, alert: "Submission rejected. Please try again."
      return
    end
    
    @joke = Joke.new(joke_params)
    
    if verify_recaptcha(model: @joke) && @joke.save
      redirect_to new_joke_path, notice: 'Thank you! Your joke has been submitted and is pending review.'
    else
      # Add custom error message if reCAPTCHA failed
      unless verify_recaptcha(model: @joke)
        @joke.errors.add(:base, "Please complete the reCAPTCHA verification.")
      end
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @joke.update(status_params)
      redirect_to jokes_path, notice: "Joke status updated to #{@joke.status.humanize}."
    else
      redirect_to jokes_path, alert: "Failed to update joke status."
    end
  end

  private

  def set_joke
    @joke = Joke.find(params[:id])
  end

  def joke_params
    params.require(:joke).permit(:question, :answer)
  end

  def status_params
    params.require(:joke).permit(:status)
  end
end
