namespace :beehiiv do
  desc "Create daily Beehiiv post (uses credentials for API key and publication ID)"
  task :create_daily_post => :environment do
    begin
      CreateDailyBeehiivPostJob.perform_now
      puts "✅ Daily Beehiiv post creation job completed successfully!"
    rescue StandardError => e
      puts "❌ Error running daily post job: #{e.message}"
      exit 1
    end
  end

  desc "Test the daily Beehiiv post job without actually creating a post"
  task :test_daily_job => :environment do
    begin
      service = BeehiivApi::CreatePost.new
      joke = service.send(:joke)
      
      if joke
        puts "✅ Job would succeed!"
        puts "   Joke to be used: #{joke.prompt}"
        puts "   Punchline: #{joke.punchline}" if joke.punchline.present?
        puts "   Submitted by: #{joke.submitted_by}" if joke.submitted_by.present?
      else
        puts "❌ Job would fail: No approved jokes available without posts"
      end
    rescue StandardError => e
      puts "❌ Job would fail: #{e.message}"
    end
  end

  desc "List approved jokes without posts"
  task :list_available_jokes => :environment do
    jokes = Joke.joins("LEFT JOIN posts ON jokes.id = posts.joke_id")
                .where(status: :approved, posts: { id: nil })
                .order(:created_at)
    
    if jokes.empty?
      puts "No approved jokes available without posts."
    else
      puts "Available jokes (#{jokes.count}):"
      jokes.each_with_index do |joke, index|
        puts "#{index + 1}. #{joke.prompt}"
        puts "   Punchline: #{joke.punchline}" if joke.punchline.present?
        puts "   Created: #{joke.created_at.strftime('%Y-%m-%d %H:%M')}"
        puts
      end
    end
  end
end
