require 'json'
require 'nokogiri'

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

  class Leader
    PATTERN = /^\/nba leader\s*([1-2][9,0][0-9]{2}-[0-9][1-2]-[0-3][0-9])*$/
    FIC_URI = 'http://basketball.realgm.com/nba/daily-leaders/'
    def cmd_name
      "/nba leader {+date}"
    end

    def manual
      "\n     NBA 今日球員榜 Top 10 (Rank by FIC[Floor Impact Counter])" +
      "\n     也可查詢過去日期 e.g. /nba leader 2016-11-01"
    end

    def reply(text)
      {
        type: :text,
        text: "NBA Today's PIC Rank - Name - PIC \n\n #{leaders.join("\n\n")}"
      }
    end

    private
    def leaders(date = nil)
      daily_leaders.map {|player| "#{player[:rank]} - #{player[:name]} - #{player[:pic]}"}
    end

    def daily_leaders(date = nil)
      uri = NBA::Leader::FIC_URI
      if date
        date = Date.parse date
        uri += date.to_s
      end
      result = []
      dl = Nokogiri::HTML(open(uri))
      top_ten = dl.search('table.tablesaw>tbody>tr')[0..9]
      top_ten.each do |player_dom|
        player_values = player_dom.search('td')
        player_rank = player_values[0].content
        player_name = player_values[1].content
        player_pic = player_values[19].content
        result << {
          rank: player_rank,
          name: player_name,
          pic: player_pic
        }
      end
      result
    end
  end
end

Cabot::Core::CommandProcessor.register_rule(NBA::Today::PATTERN, NBA::Today)
Cabot::Core::CommandProcessor.register_rule(NBA::Leader::PATTERN, NBA::Leader)
