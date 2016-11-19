require 'bing_translator'
require 'cabot/core/command_processor'
class Fy
  def initialize
    @translator ||= BingTranslator.new(ENV['AZURE_CLIENT_ID'], ENV['AZURE_CLIENT_SECRET'])
  end

  def reply(text)
    fy_msg_segment = text.split('/fy ')
    word = fy_msg_segment[1].to_s
    from_lang = translator.detect word
    to_lang = nil
    puts "from #{from_lang} to #{to_lang}"
    if %w(zh-CHT zh-CHS).include? from_lang.to_s
      to_lang = :en
    else
      to_lang = 'zh-CHT'
    end
    puts "from #{from_lang} to #{to_lang}"
    translate_result = translator.translate(word, form: from_lang, to: to_lang)
    {
      type: :text,
      text: translate_result
    }
  end

  private
  def translator
    @translator
  end
end

Cabot::Core::CommandProcessor.register_rule(/^\/fy\s[\w\W]+/, Fy)
