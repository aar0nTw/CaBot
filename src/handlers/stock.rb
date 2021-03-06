require 'json'
require 'cabot/core/command_processor'

class Stock
  PATTERN = /^\/stock\s([\w\W]+)/
  def cmd_name
    "/stock {stock code}"
  end

  def manual
    "股票資訊"
  end

  def reply(text)
    resp = []
    stock_id = text.match(Stock::PATTERN).captures[0]

    resp.push({
      type: :image,
      originalContentUrl: image_url(stock_id),
      previewImageUrl: image_url(stock_id)
    })

    resp.push({
      type: :template,
      altText: stock_details(stock_id),
      template: {
        type: :buttons,
        title: stock_id,
        thumbnailImageUrl: image_url(stock_id),
        text: " ",
        actions: [{
          type: :uri,
          label: "Yahoo Finance",
          uri: stock_details(stock_id)
        }]
      }
    })
  end

  def stock_details(stock_id)
    URI.escape("http://finance.yahoo.com/quote/#{stock_id}")
  end

  def image_url(stock_id)
     URI.escape("https://ichart.yahoo.com/t?s=#{stock_id}&time=#{Time.now.to_i.to_s[0..-2]}")
  end
end

Cabot::Core::CommandProcessor.register_rule(Stock::PATTERN, Stock)
