require 'opendmm'

class AV
  PATTERN = /^\/av\s([\w\W]+)/

  def cmd_name
    "/av {av_no}"
  end

  def manual
    "番號搜尋器"
  end

  def reply(text)
    resp = []
    key_word = AV::PATTERN.match(text).captures[0]
    dmm_result = OpenDMM.search key_word
    if dmm_result
      cover_uri = URI(dmm_result[:cover_image])
      resp.push({
        type: :image,
        originalContentUrl: "https://#{cover_uri.host + cover_uri.path}",
        previewImageUrl: "https://#{cover_uri.host + cover_uri.path}"
      })
      actor = ""
      if !dmm_result[:actresses].nil?
        actor = dmm_result[:actresses].join(',')
      end
      resp.push({
        type: :text,
        text: "#{dmm_result[:title]}: #{actor}"
      })
    end
    resp
  end
end

Cabot::Core::CommandProcessor.register_rule(AV::PATTERN, AV)
