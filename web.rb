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
  player_uri = URI("http://stats-prod.nba.com/wp-json/statscms/v1/rotowire/player/?playerId=#{player_id}&limit=2")
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
      message = nil
      rich_message = nil
      case event.type
      when Line::Bot::Event::MessageType::Text
        receive_message = event.message['text'].downcase
        nba_msg_segment = receive_message.split('nba player ')
        twstock_msg_segment = receive_message.split('stock ')
        cmd_nba_flag = nba_msg_segment.length > 1
        cmd_stock_flag = twstock_msg_segment.length > 1
        if cmd_nba_flag
          puts 'Confirm'
          player_name = nba_msg_segment[1].gsub(/[^a-zA-Z0-9\-_]+/, '_').downcase
          player_id = player_map[player_name]
          if player_id != nil
            puts "Loading player...#{player_name} #{player_id}"
            player_news = get_player_news_by_id(player_id)
            puts player_news
            if player_news
              puts "use template for #{player_id}"
              first_news = player_news['PlayerRotowires'][0]
              message = {
                type: :template,
                altText: "[#{first_news['Team']}] #{first_news['FirstName']} #{first_news['LastName']}: http://stats.nba.com/player/#!/#{player_id}",
                template: {
                  type: :buttons,
                  title: "[#{first_news['Team']}] #{first_news['FirstName']} #{first_news['LastName']}",
                  text: first_news['ListItemCaption'][0..40],
                  actions: [
                    {
                      type: :uri,
                      label: '球員資訊',
                      uri: "http://stats.nba.com/player/#!/#{player_id}"
                    }
                  ]
                }
              }
            else
              message = {
                type: :text,
                text: "#{player_name} 沒新聞"
              }
            end
          else
              message = {
                type: :text,
                text: "沒找到 #{player_name}"
              }
          end
        end

        if cmd_stock_flag
          stock_id = twstock_msg_segment[1]
          image_url = URI.escape("https://ichart.yahoo.com/t?s=#{stock_id}")
          message = {
            type: "image",
            originalContentUrl: image_url,
            previewImageUrl: image_url,
          }
          puts "imageurl = #{image_url}"
          rich_message = {
            type: :template,
            altText: "http://finance.yahoo.com/quote/#{stock_id}",
            template: {
              type: :buttons,
              title: stock_id,
              thumbnailImageUrl: image_url,
              text: nil,
              actions: [{
                type: :uri,
                label: "Yahoo Finance",
                uri: "http://finance.yahoo.com/quote/#{stock_id}"
              }]
            }
          }
        end

        messages = []
        if message
          messages << message
        end
        if rich_message
          messages << rich_message
        end
        puts "Handle message: #{messages}, #{messages.length}"
        puts event['replyToken']
        response = client.reply_message(event['replyToken'], messages)
        puts "req reply resp: #{response.body}"
      end
    end
  end

  "OK"
end
