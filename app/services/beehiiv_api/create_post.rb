# frozen_string_literal: true

require 'net/http'
require 'json'

module BeehiivApi
  class CreatePost
    attr_reader :publication_id, :api_key, :beehiiv_response

    def initialize(joke: nil)
      @publication_id = Rails.application.credentials.beehiiv_publication_id
      @api_key = Rails.application.credentials.beehiiv_api_key
      @joke = joke
    end

    def perform
      raise ArgumentError, "beehiiv API key not found in credentials" unless api_key
      raise ArgumentError, "beehiiv Publication ID not found in credentials" unless publication_id

      raise StandardError, "No approved jokes available without posts" unless joke

      @beehiiv_response = create_beehiiv_post
      create_local_post
    end

    private

    def joke
      @joke ||= Joke.approved.where.missing(:post).first
    end

    def recipient_segment_id
      "seg_f4ce5771-9347-4349-b330-2956ed64bdab"
    end

    def create_beehiiv_post
      uri = URI.parse("https://api.beehiiv.com/v2/publications/#{publication_id}/posts")
      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Bearer #{api_key}"
      request["Content-Type"] = "application/json"
      request.body = build_post_payload.to_json

      req_options = { use_ssl: uri.scheme == "https" }
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      unless response.is_a?(Net::HTTPSuccess)
        raise StandardError, "Failed to create Beehiiv post. Response: #{response.code} - #{response.body}"
      end

      JSON.parse(response.body)
    end

    def build_post_payload
      {
        title: "Daily Dad Joke - #{scheduled_at.strftime('%B %d, %Y')}",
        subtitle: joke.prompt.truncate(80),
        blocks: generate_content_blocks,
        status: "confirmed",
        scheduled_at: scheduled_at,
        recipients: { web: { tier_ids: [ "free" ] }, email: { tier_ids: [ "free" ] } }
      }
    end

    def scheduled_at
      @scheduled_at ||= Time.current.utc.tomorrow.change(hour: 15, min: 0, sec: 0) # Schedule for 10 AM EST
    end

    def generate_content_blocks
      blocks = []

      blocks << {
        type: "quote",
        quote: joke.prompt,
        author: joke.punchline
      }

      if joke.submitted_by.present?
        blocks << {
          type: "paragraph",
          formattedText: [
            {
              text: "Submitted By: #{joke.submitted_by.humanize}",
              styling: [ "italic"]
            }
          ]
        }
      end

      blocks << {
        type: "paragraph",
        formattedText: [
          {
            text: "Have a joke to share? Submit your own and it might be featured in the next Daily Dad Joke!",
            styling: [ "italic" ]
          }
        ]
      }

      blocks << {
        type: "button",
        text: "Submit a Joke",
        href: "https://app.thedailydadjoke.com/jokes/new?email={{email}}",
        alignment: "center",
        size: "normal"
      }

      blocks << {
        type: "poll",
        poll_id: "poll_fed66a9c-e7bc-4190-8460-a84c45ab357d"
      }

      blocks
    end

    def create_local_post
      beehiiv_post_id = beehiiv_response.dig("data", "id")

      Post.create!(
        joke: joke,
        beehiiv_post_id: beehiiv_post_id
      )
    end
  end
end
