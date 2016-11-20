require 'bing_translator'
require 'cabot/core/command_processor'

class Fy
  PATTERN = /^\/fy\s([\w\W]+)/
  attr_reader :cmd_name
  attr_reader :manual

  def initialize
    @cmd_name = "/fy {text}"
    @manual = "自動翻譯"
    @translator ||= BingTranslator.new(ENV['AZURE_CLIENT_ID'], ENV['AZURE_CLIENT_SECRET'])
  end

  def reply(text)
    word = text.match(Fy::PATTERN).captures[0]
    from_lang = translator.detect word
    to_lang = nil

    if %w(zh-CHT zh-CHS).include? from_lang.to_s
      to_lang = :en
    else
      to_lang = 'zh-CHT'
    end

    translate_result = translator.translate(word, form: from_lang, to: to_lang)
    return {
      type: :text,
      text: translate_result
    }
  end

  private
  attr_reader :translator
end

Cabot::Core::CommandProcessor.register_rule(Fy::PATTERN, Fy)
