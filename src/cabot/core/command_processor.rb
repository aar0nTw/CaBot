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
          rules_hash[regex] = handler.new.method :reply
        end

        def match(text)
          # for /help command
          if HELP_PATTERN.match text
            return help
          end
          rules_hash.each do |regex, reply|
            if regex.match text
              return reply.call text
            end
          end
          []
        end

        def help
          text = rules_hash.map {|regex, reply| "#{reply.cmd_name}: #{reply.manual}"}.join('\n')
          {
            type: :text,
            text: text
          }
        end
      end
    end
  end
end
