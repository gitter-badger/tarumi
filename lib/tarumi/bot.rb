require 'httparty'

module Tarumi
  class Bot
    include HTTParty

    attr_reader :options, :username, :channel,
                :hook_name

    # Add the default format to be json on each request
    format :json

    # We don't want Rails to be nasty with the parameters we send
    disable_rails_query_string_format if defined?(Rails)

    def initialize(team, token, options = {})
      self.class.base_uri("https://#{team}.slack.com") 
      self.class.default_params(token: token) #we sent this token on each request

      @username = options[:username] || "webhookbot"
      @channel = options[:channel] || "#general"
      @hook_name = options[:hook_name] || "incoming-webhook"

      raise ArgumentError, 'You need to specify a team' if team.blank?
      raise ArgumentError, 'You need to specify the token, to get one go to https://yourteamname.slack.com/services/new' if token.blank?
    end

    def ping(text, options = {})
      payload = { text: text, channel: @channel, username: @username }.merge(options)
      body = { body: "payload=#{payload.to_json}"}

      response = self.class.post("/services/hooks/#{@hook_name}", body) 

      raise ArgumentError, 'You need to specify a text' if text.blank?

      "#{response.body} - #{response.code}"
    end

  end
end
