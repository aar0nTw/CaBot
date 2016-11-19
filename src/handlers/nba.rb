require 'json'

module NBA
  class Today
    PATTERN = /^\/nba today$/
    TODAY_URI = URI('http://data.nba.com/data/v2015/json/mobile_teams/nba/2016/scores/00_todays_scores.json')
    def cmd_name
      "/nba today"
    end

    def manual
      "NBA 今日比數"
    end

    def reply(text)
      result_texts = today_json[:games].map {|game| game[:status] + "\n" + game[:text]}
      {
        type: :text,
        text: "#{today_json[:date]} NBA 即時比數 \n #{result_texts.join("\n\n")}"
      }
    end

    private
    def today_json
      data = nba_today_data
      game_stat = data['gs']
      game_date = game_stat['gdte']
      games = game_stat['g']
      resp = {}
      resp[:date] = game_date
      resp[:games] = []
      games.each do |game|
        obj = {}
        obj = {
          status: "[#{game['v']['ta']}] vs [#{game['h']['ta']}]",
          text: "[#{game['stt']} #{game['cl']}] #{game['v']['s']} :  #{game['h']['s']}"
        }
        resp[:games] << obj
      end
      resp
    end
    def nba_today_data
      response = Net::HTTP.get NBA::Today::TODAY_URI
      JSON.parse(response)
    end

  end
end

Cabot::Core::CommandProcessor.register_rule(NBA::Today::PATTERN, NBA::Today)
