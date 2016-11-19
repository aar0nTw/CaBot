module Cabot
  module Core
    class CommandProcessor
      class << self
        HELP_PATTERN = /^\/help/
        @@rules_hash = {}
        def rules_hash
          @@rules_hash
        end

        def register_rule(regex, handler)
          rules_hash[regex] = handler.new
        end

        def match(text)
          # for /help command
          if HELP_PATTERN.match text
            return help
          end
          rules_hash.each do |regex, handler|
            if regex.match text
              return handler.reply text
            end
          end
          []
        end

        def help
          text = rules_hash.map {|regex, handler| "#{handler.cmd_name}: #{handler.manual}"}.join("\n")
          {
            type: :text,
            text: text
          }
        end
      end
    end
  end
end
