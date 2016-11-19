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
          puts text
          puts "rules_hash: #{rules_hash}"
          rules_hash.each do |regex, func|
            puts "#{regex}: #{func}"
            if regex.match text
              return func.call text
            end
          end
          []
        end

      end
    end
  end
end
