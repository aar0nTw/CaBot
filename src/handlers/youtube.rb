require 'json'

class Youtube
  PATTERN = /^\/youtube\s([\w\W]+)/
  YOUTUB_API_URI = "https://www.googleapis.com/youtube/v3/search?part=snippet&key=#{ENV['GOOGLE_API_KEY']}&maxResults=1"
  VIDEO = 'youtube#video'
  CHANNEL = 'youtube#channel'
  PLAYLIST = 'youtube#playlist'

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
    if video
      kind = video['id']['kind']
      snippet = video['snippet']
      thumbnail = snippet['thumbnails']['medium']['url']
      title = snippet['title']
      description = snippet['description']
      case kind
      when VIDEO
        video_path = "https://youtu.be/#{video['id']['videoId']}"
      when CHANNEL
        video_path = "https://youtu.be/#{video['id']['channelId']}"
      when PLAYLIST
        video_path = "https://www.youtube.com/playlist?list=#{video['id']['playlistId']}"
      end

      resp.push({
        type: :image,
        originalContentUrl: thumbnail,
        previewImageUrl: thumbnail
      })

      resp.push({
        type: :text,
        text: "#{title}\n#{description}\n#{video_path}\n"
      })
    else
      resp.push({
        type: :text,
        text: '找不到影片。'
      })
    end
  end

  def get_youtube_results(keyword)
    uri =  URI("#{Youtube::YOUTUB_API_URI}&q=#{URI.escape(keyword)}")
    response = Net::HTTP.get uri
    JSON.parse(response)
  end

end

Cabot::Core::CommandProcessor.register_rule(Youtube::PATTERN, Youtube)
