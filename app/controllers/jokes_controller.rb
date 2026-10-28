class JokesController < ApplicationController
  include RateLimiting

  before_action :authenticate_user!, only: [ :index, :update ]
  before_action :rate_limit_submission, only: [ :create ], unless: :user_signed_in?
  before_action :joke, only: [ :update ]
  layout "public", only: [ :new, :create ]

  def index
    pending_count = Joke.pending.count
    approved_count = Joke.approved.count
    rejected_count = Joke.rejected.count
    used_count = Joke.used.count
    available_count = Joke.available.count

    # Apply pagination to filtered results
    jokes_list = jokes.paginate(page: params[:page], per_page: 12)

    render locals: {
      jokes: jokes_list,
      pending_count: pending_count,
      approved_count: approved_count,
      rejected_count: rejected_count,
      used_count: used_count,
      available_count: available_count,
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
    joke.status = :approved if user_signed_in?

    # reCAPTCHA verification
    recaptcha_valid = user_signed_in? || verify_recaptcha(action: "submit_joke", minimum_score: 0.8)

    if recaptcha_valid && joke.save
      notice = joke.approved? ? "Joke added and approved." : "Thank you! Your joke has been submitted and is pending review."
      redirect_to new_joke_path, notice: notice
    else
      unless recaptcha_valid
        joke.errors.add(:base, "Security verification failed. Please try again.")
      end
      render :new, status: :unprocessable_entity, locals: { joke: joke }
    end
  end

  def update
    redirect_path = jokes_path(status: params[:redirect_status] || "pending")

    if @joke.update(update_params)
      notice = @joke.status_previously_changed? ? "Joke status updated to #{@joke.status.humanize}." : "Joke updated."
      redirect_to redirect_path, notice: notice
    else
      redirect_to redirect_path, alert: @joke.errors.full_messages.to_sentence.presence || "Joke could not be updated."
    end
  end

  private

  def jokes
    return @jokes if defined?(@jokes)

    @jokes = if filter_status.in? Joke.statuses.keys
      Joke.where(status: filter_status)
    elsif filter_status.in? %w[used available]
      Joke.public_send(filter_status)
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

  def update_params
    params.require(:joke).permit(:status, :prompt, :punchline, :submitted_by)
  end
end
