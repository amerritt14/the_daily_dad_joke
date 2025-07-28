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

namespace :admin do
  desc "Send admin summary emails to all users"
  task :send_summary_emails => :environment do
    begin
      SendAdminSummaryEmailsJob.perform_now
      puts "✅ Admin summary emails job completed successfully!"
    rescue StandardError => e
      puts "❌ Error running admin summary emails job: #{e.message}"
      exit 1
    end
  end

  desc "Send test admin summary email to a specific user"
  task :send_test_email, [:email] => :environment do |t, args|
    email = args[:email]
    
    if email.blank?
      puts "Error: Email address is required"
      puts "Usage: rails admin:send_test_email[user@example.com]"
      exit 1
    end

    user = User.find_by(email: email)
    unless user
      puts "❌ User with email '#{email}' not found"
      exit 1
    end

    begin
      AdminNotificationMailer.pending_jokes_summary(user).deliver_now
      puts "✅ Test admin summary email sent to #{email}"
    rescue StandardError => e
      puts "❌ Error sending test email: #{e.message}"
      exit 1
    end
  end

  desc "Preview admin summary email stats"
  task :preview_summary => :environment do
    pending_count = Joke.pending.count
    approved_count = Joke.approved.count
    rejected_count = Joke.rejected.count
    total_count = Joke.count
    user_count = User.count

    puts "📊 Admin Summary Preview"
    puts "========================"
    puts "Users who will receive emails: #{user_count}"
    puts "Pending jokes: #{pending_count}"
    puts "Approved jokes: #{approved_count}"
    puts "Rejected jokes: #{rejected_count}"
    puts "Total jokes: #{total_count}"
    puts
    
    if pending_count > 0
      puts "Recent pending jokes:"
      Joke.pending.order(created_at: :desc).limit(3).each do |joke|
        puts "- #{joke.prompt.truncate(60)} (#{time_ago_in_words(joke.created_at)} ago)"
      end
    else
      puts "🎉 No pending jokes to review!"
    end
  end
end
