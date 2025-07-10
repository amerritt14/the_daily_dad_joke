class JokesController < ApplicationController
  include RateLimiting

  before_action :authenticate_user!, only: [ :index, :update ]
  before_action :rate_limit_submission, only: [ :create ]
  before_action :set_joke, only: [ :update ]
  layout "public", only: [ :new, :create ]

  def index
    # Admin view - shows all jokes with status for moderation
    # Default to showing pending jokes, allow filtering by status
    @filter_status = params[:status] || "pending"

    # Get counts for status summary (always show all counts)
    @pending_count = Joke.pending.count
    @approved_count = Joke.approved.count
    @rejected_count = Joke.rejected.count

    # Filter jokes based on selected status
    @jokes = case @filter_status
    when "pending"
      Joke.pending
    when "approved"
      Joke.approved
    when "rejected"
      Joke.rejected
    when "all"
      Joke.order(
        Arel.sql("CASE WHEN status = 'pending' THEN 0 WHEN status = 'approved' THEN 1 WHEN status = 'rejected' THEN 2 END")
      )
    else
      Joke.pending # fallback to pending
    end

    # Apply pagination to filtered results
    @jokes = @jokes.order(created_at: :desc).paginate(page: params[:page], per_page: 12)
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
      redirect_to new_joke_path, notice: "Thank you! Your joke has been submitted and is pending review."
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
      # Preserve the current filter when redirecting
      redirect_to jokes_path(status: params[:redirect_status] || "pending"),
        notice: "Joke status updated to #{@joke.status.humanize}."
    else
      redirect_to jokes_path(status: params[:redirect_status] || "pending"),
        alert: "Failed to update joke status."
    end
  end

  private

  def set_joke
    @joke = Joke.find(params[:id])
  end

  def joke_params
    params.require(:joke).permit(:prompt, :punchline)
  end

  def status_params
    params.require(:joke).permit(:status)
  end
end
