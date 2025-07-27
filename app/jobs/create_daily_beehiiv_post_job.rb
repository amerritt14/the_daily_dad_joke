class CreateDailyBeehiivPostJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting daily Beehiiv post creation..."

    if joke.nil?
      Rails.logger.error "No approved jokes available without posts."
      raise StandardError, "No approved jokes available without posts"
    end

    post = BeehiivApi::CreatePost.new(joke: joke).perform

    Rails.logger.info "Successfully created Beehiiv post: #{post.beehiiv_post_id} for joke: #{post.joke.id}"
  rescue StandardError => e
    Rails.logger.error "Failed to create daily Beehiiv post: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")

    raise e
  end

  private

  def joke
    @joke ||=
      Joke.approved.order(Arel.sql("CASE WHEN submitted_by IS NOT NULL THEN 0 ELSE 1 END")).where.missing(:post).first
  end
end
