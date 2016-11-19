module Cabot
  module Core
    class CommandProcessor
      class << self
        @@rules_hash = {}
        def rules_hash
          @@rules_hash
        end

        def register_rule(regex, handler)
          rules_hash[regex] = handler.new.method :reply
        end

        def match(text)
          rules_hash.each do |regex, reply|
            if regex.match text
              return reply.call text
            end
          end
          []
        end

      end
    end
  end
end
