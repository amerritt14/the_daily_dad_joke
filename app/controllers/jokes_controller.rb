class JokesController < ApplicationController
  include RateLimiting

  before_action :authenticate_user!, only: [ :index, :update ]
  before_action :rate_limit_submission, only: [ :create ]
  before_action :joke, only: [ :update ]
  layout "public", only: [ :new, :create ]

  def index
    pending_count = Joke.pending.count
    approved_count = Joke.approved.count
    rejected_count = Joke.rejected.count

    # Apply pagination to filtered results
    jokes_list = jokes.paginate(page: params[:page], per_page: 12)

    render locals: {
      jokes: jokes_list,
      pending_count: pending_count,
      approved_count: approved_count,
      rejected_count: rejected_count,
      filter_status: filter_status
    }
  end

  def new
    joke = Joke.new
    render locals: { joke: joke }
  end

  def create
    # Check honeypot field, if present show the success message (to fool bots)
    if params.dig(:joke, :website).present?
      redirect_to new_joke_path, notice: "Thank you! Your joke has been submitted and is pending review."
      return
    end

    joke = Joke.new(joke_params)

    # reCAPTCHA verification
    recaptcha_valid = verify_recaptcha(action: "submit_joke", minimum_score: 0.8)

    if recaptcha_valid && joke.save
      redirect_to new_joke_path, notice: "Thank you! Your joke has been submitted and is pending review."
    else
      unless recaptcha_valid
        joke.errors.add(:base, "Security verification failed. Please try again.")
      end
      render :new, status: :unprocessable_entity, locals: { joke: joke }
    end
  end

  def update
    if @joke.update(status_params)
      redirect_to jokes_path(status: params[:redirect_status] || "pending"),
        notice: "Joke status updated to #{@joke.status.humanize}."
    else
      redirect_to jokes_path(status: params[:redirect_status] || "pending"),
        alert: "Failed to update joke status."
    end
  end

  private

  def jokes
    return @jokes if defined?(@jokes)

    @jokes = if filter_status.in? Joke.statuses.keys
      Joke.where(status: filter_status)
    else
      Joke.all.order(
        Arel.sql(
          "CASE WHEN status = 'pending' THEN 0 WHEN status = 'approved' THEN 1 WHEN status = 'rejected' THEN 2 END"
        )
      )
    end
  end

  def filter_status
    @filter_status ||= params[:status].presence || "pending"
  end

  def joke
    @joke = Joke.find(params[:id])
  end

  def joke_params
    params.require(:joke).permit(:prompt, :punchline, :submitted_by)
  end

  def status_params
    params.require(:joke).permit(:status)
  end
end
