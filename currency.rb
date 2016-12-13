require 'json'
require 'net/http'

class Currency
  PATTERN = /^([0-9]+)\s([a-zA-Z]{3})\sto\s([a-zA-Z]{3})/
  API_KEY = ENV['CURRENCY_API_KEY']
  API_URI = 'http://apilayer.net/api/live'
  attr_reader :cmd_name
  attr_reader :manual

  def initialize
    @cmd_name = "貨幣轉換"
    @manual = "Ex: 200 twd to usd"
  end

  def currency_live(from, to)
    uri = URI("#{API_URI}?access_key=#{API_KEY}&currencies=#{from},#{to}&format=1")
    response = Net::HTTP.get uri
    JSON.parse(response)
  end

  def reply(text)
    resp = []
    matches = Currency::PATTERN.match(text)
    num, from, to = matches.captures
    quotes_key = "#{from}#{to}".upcase
    transfer_data = currency_live from, to
    quotes = transfer_data['quotes']
    ratio = quotes[quotes_key]
    if ratio
      target = num.to_i * ratio.to_i
      resp.push({
        type: :text,
        text: "#{num} #{from} 約等於 #{target} #{to}"
      })
    else
      resp.push({
        type: :text,
        text: "查無結果"
      })
    end
    resp
  end
end

Cabot::Core::CommandProcessor.register_rule(Currency::PATTERN, Currency)
