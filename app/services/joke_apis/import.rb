# frozen_string_literal: true

module JokeApis
  class Import
    attr_reader :api, :api_details, :api_url, :headers, :max_limit, :timeout

    def initialize(api: :icanhazdadjoke)
      @api = api
      @api_details = Rails.application.config_for(:joke_api_details)[api].with_indifferent_access
      @api_url = @api_details["api_url"]
      @headers = @api_details["headers"] || {}
      @timeout = @api_details["timeout"] || 5
      @max_limit = @api_details["max_limit"] || 30
    end

    def perform
      fetch_jokes
      puts "Finished fetching jokes from #{api}"
    end

    private

    def fetch_jokes(page: 1)
      puts "Fetching jokes from #{api} (page: #{page})..."
      uri = URI.parse(api_url)
      params = { "limit" => max_limit, "page" => page }
      uri.query = URI.encode_www_form(params)
      request = Net::HTTP::Get.new(uri)
      headers.each do |key, value|
        request[key] = value
      end
      req_options = { use_ssl: uri.scheme == "https" }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      unless response.is_a?(Net::HTTPSuccess)
        raise StandardError, "Failed to fetch jokes from #{api}. Response: #{response.body}"
      end

      data = JSON.parse(response.body)
      jokes = data["results"]
      jokes.each do |joke|
        create_joke(joke) unless Joke.exists?(source_id: joke["id"])
      end
      next_page = data["next_page"]
      if next_page && next_page != page
        sleep(timeout)
        fetch_jokes(page: next_page)
      end
    end

    def create_joke(data)
      if data["joke"].include?("?")
        prompt, punchline = data["joke"].split("?").map(&:strip)
        prompt += "?" unless prompt.end_with?("?")
      else
        prompt = data["joke"]
        punchline = nil
      end

      Joke.create(
        prompt: prompt,
        punchline: punchline,
        source: api.to_s,
        source_id: data["id"],
        status: :approved
      )
    end
  end
end
