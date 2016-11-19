require 'line/bot'
require 'cabot/core/command_processor'

module Cabot
  class Cabot
    def initialize(channel_secret, channel_token)
      @client = Line::Bot::Client.new { |config|
        config.channel_secret = channel_secret
        config.channel_token = channel_token
      }
      @reply_token = nil
    end

    def handle(request)
      body = request.body.read

      signature = request.env['HTTP_X_LINE_SIGNATURE']
      unless client.validate_signature(body, signature)
        return false
      end

      events = client.parse_events_from(body)
      events.map do |event|
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text
            @reply_token = event['replyToken']
            send_messages Core::CommandProcessor.match event.message['text'].downcase
          end
        end
      end
    end

    def send_messages(messages = [])
      if messages && messages.any?
        client.reply_message(reply_token, messages)
        return true
      end
      false
    end

    def client
      @client
    end

    def reply_token
      @reply_token
    end

  end
end
