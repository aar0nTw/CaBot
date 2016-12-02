require 'json'

class Youtube
  PATTERN = /^\/youtube\s([\w\W]+)/
  YOUTUB_API_URI = "https://www.googleapis.com/youtube/v3/search?part=snippet&key=#{ENV['GOOGLE_API_KEY']}&maxResults=1"

  def cmd_name
    "/youtube {key_word}"
  end

  def manual
    "Youtube 影片"
  end

  def reply(text)
    resp = []
    keyword = text.match(Youtube::PATTERN).captures[0]
    results = get_youtube_results keyword
    video = results['items'][0]
    thumbnail = video['snippet']['thumbnails']['default']['url']
    video_path = "https://youtu.be/#{video['id']['videoId']}"

    resp.push({
      type: :image,
      originalContentUrl: thumbnail,
      previewImageUrl: thumbnail
    })

    resp.push({
      type: :text,
      text: video_path
    })
  end

  def get_youtube_results(keyword)
    uri =  URI("#{Youtube::YOUTUB_API_URI}&q=#{keyword}")
    response = Net::HTTP.get uri
    JSON.parse(response)
  end

end

Cabot::Core::CommandProcessor.register_rule(Youtube::PATTERN, Youtube)
