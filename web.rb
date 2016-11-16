require 'sinatra'
require 'sinatra/logger'
require 'line/bot'
require 'net/http'
require 'json'

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

def request_nba_stat
  results = {}
  nba_stat_uri = URI('http://stats.nba.com/stats/commonallplayers?IsOnlyCurrentSeason=0&LeagueID=00&Season=2016-17')
  response = Net::HTTP.get(nba_stat_uri)
  data = JSON.parse(response)
  data['resultSets'][0]['rowSet'].each do |player|
    player_id = player[0]
    full_name = player[2].gsub(/[^a-zA-Z0-9\-_]+/, '_').downcase
    results[full_name] = player_id
  end
  results
end

def get_player_news_by_id(player_id)
  player_uri = URI('http://stats-prod.nba.com/wp-json/statscms/v1/rotowire/player/?playerId=2544&limit=2')
  response = Net::HTTP.get(player_uri)
  data = JSON.parse(response)
end

player_map = request_nba_stat

configure do
  enable :logging
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each do |event|
    puts event.message
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        receive_message = event.message['text']

        nba_msg_segment = receive_message.split('nba player ')
        cmd_nba_flag = nba_msg_segment.length > 1
        if cmd_nba_flag
          puts 'Confirm'
          player_name = nba_msg_segment[1].gsub(/[^a-zA-Z0-9\-_]+/, '_').downcase
          player_id = player_map[player_name]
          if player_id != nil
            puts "Loading player..."
            player_news = get_player_news_by_id(player_id)
            puts player_news
            if player_news.length > 0
              message = {
                type: 'template',
                altText: "http://stats.nba.com/player/#!/#{player_id}",
                template: {
                  type: 'buttons',
                  title: "#{player_name}",
                  text: player_news[0]['ListItemCaption'],
                  actions: [
                    {
                      type: 'uri',
                      label: '球員資訊',
                      uri: "http://stats.nba.com/player/#!/#{player_id}"
                    }
                  ]
                }
              }
            else
              message = {
                type: 'text',
                text: "#{player_name} 沒新聞"
              }
            end
          else
              message = {
                type: 'text',
                text: "沒找到 #{player_name}"
              }
          end
          puts event['replyToken']
          response = client.reply_message(event['replyToken'], message)
          puts response
        end

      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)
      end
    end
  end

  "OK"
end
