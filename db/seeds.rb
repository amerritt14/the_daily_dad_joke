# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create admin user for jokes access
if Rails.env.development?
  admin_email = "admin@dailydadjoke.com"
  admin_password = "password123"

  unless User.exists?(email: admin_email)
    User.create!(
      email: admin_email,
      password: admin_password,
      password_confirmation: admin_password
    )
    puts "Created admin user: #{admin_email} / #{admin_password}"
  end

  # Create sample jokes if none exist
  if Joke.count == 0
    sample_jokes = [
      {
        prompt: "Why don't scientists trust atoms?",
        punchline: "Because they make up everything!",
        status: "approved"
      },
      {
        prompt: "What do you call a fake noodle?",
        punchline: "An impasta!",
        status: "approved"
      },
      {
        prompt: "Why did the scarecrow win an award?",
        punchline: "He was outstanding in his field!",
        status: "approved"
      },
      {
        prompt: "What do you call a bear with no teeth?",
        punchline: "A gummy bear!",
        status: "approved"
      },
      {
        prompt: "Why don't eggs tell jokes?",
        punchline: "They'd crack each other up!",
        status: "approved"
      }
    ]

    sample_jokes.each do |joke_attrs|
      Joke.create!(joke_attrs)
    end

    # Add some pending jokes for admin review
    pending_jokes = [
      {
        prompt: "What's the best thing about Switzerland?",
        punchline: "I don't know, but the flag is a big plus!",
        status: "pending"
      },
      {
        prompt: "How do you organize a space party?",
        punchline: "You planet!",
        status: "pending"
      }
    ]

    pending_jokes.each do |joke_attrs|
      Joke.create!(joke_attrs)
    end

    puts "Created #{sample_jokes.count} approved jokes and #{pending_jokes.count} pending jokes"
  end
end
