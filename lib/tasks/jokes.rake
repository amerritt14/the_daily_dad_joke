# frozen_string_literal: true

namespace :jokes do
  desc "Import jokes from a specific API (e.g., rake jokes:import[icanhazdadjoke])"
  task :import, [:api] => :environment do |_task, args|
    api = (args[:api].presence || :icanhazdadjoke).to_sym
    puts "Starting joke import from #{api}..."

    begin
      JokeApis::Import.new(api: api).perform
      puts "✅ Joke import from #{api} completed successfully!"
    rescue StandardError => e
      puts "❌ Error during joke import from #{api}: #{e.message}"
      puts e.backtrace.join("\n") if Rails.env.development?
      exit 1
    end
  end
end
