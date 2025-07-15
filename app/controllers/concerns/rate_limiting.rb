module RateLimiting
  extend ActiveSupport::Concern

  private

  def rate_limit_submission
    # Allow only 10 submissions per IP per 10 minutes (increased from 3 per hour)
    key = "joke_submissions:#{request.remote_ip}"
    count = Rails.cache.read(key) || 0

    if count >= 10
      redirect_to new_joke_path, alert: "Too many submissions from your IP address. Please try again later."
      return false
    end

    # Increment counter with 10 minute expiration
    Rails.cache.write(key, count + 1, expires_in: 10.minutes)
    true
  end
end
