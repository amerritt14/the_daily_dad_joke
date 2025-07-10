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
        question: "Why don't scientists trust atoms?",
        answer: "Because they make up everything!",
        status: "approved"
      },
      {
        question: "What do you call a fake noodle?",
        answer: "An impasta!",
        status: "approved"
      },
      {
        question: "Why did the scarecrow win an award?",
        answer: "He was outstanding in his field!",
        status: "approved"
      },
      {
        question: "What do you call a bear with no teeth?",
        answer: "A gummy bear!",
        status: "approved"
      },
      {
        question: "Why don't eggs tell jokes?",
        answer: "They'd crack each other up!",
        status: "approved"
      }
    ]

    sample_jokes.each do |joke_attrs|
      Joke.create!(joke_attrs)
    end
    
    # Add some pending jokes for admin review
    pending_jokes = [
      {
        question: "What's the best thing about Switzerland?",
        answer: "I don't know, but the flag is a big plus!",
        status: "pending"
      },
      {
        question: "How do you organize a space party?",
        answer: "You planet!",
        status: "pending"
      }
    ]
    
    pending_jokes.each do |joke_attrs|
      Joke.create!(joke_attrs)
    end
    
    puts "Created #{sample_jokes.count} approved jokes and #{pending_jokes.count} pending jokes"
  end
end
