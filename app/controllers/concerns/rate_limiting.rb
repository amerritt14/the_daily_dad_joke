module RateLimiting
  extend ActiveSupport::Concern

  private

  def rate_limit_submission
    # Allow only 3 submissions per IP per hour
    key = "joke_submissions:#{request.remote_ip}"
    count = Rails.cache.read(key) || 0

    if count >= 3
      redirect_to new_joke_path, alert: "Too many submissions from your IP address. Please try again later."
      return false
    end

    # Increment counter with 1 hour expiry
    Rails.cache.write(key, count + 1, expires_in: 1.hour)
    true
  end
end
