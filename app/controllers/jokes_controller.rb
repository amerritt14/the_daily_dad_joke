class JokesController < ApplicationController
  include RateLimiting
  
  before_action :authenticate_user!, only: [:index]
  before_action :rate_limit_submission, only: [:create]
  layout 'public', only: [:new, :create]

  def index
    # Admin view - shows all jokes with status for moderation
    @jokes = Joke.all.order(created_at: :desc)
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

  private

  def joke_params
    params.require(:joke).permit(:question, :answer)
  end
end
