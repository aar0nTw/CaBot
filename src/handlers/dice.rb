require 'games_dice'

class Dice
  PATTERN = /^\/dice\s([\w\W]+)/

  def cmd_name
    "/dice {dice_desc}"
  end

  def manual
    "擲骰子 e.g. 3d6+3 => 最少 3 點, 三顆六面骰 = 3~21"
  end

  def reply(text)
    segment = text.match(PATTERN).captures[0]
    puts segment
    dice = GamesDice.create segment
    dice.roll
    prefix = nil
    if !dice.nil?
      if (desc =~ /^4d6$/) != nil
        prefix = "西八辣！"
      end
      {
        type: :text,
        text: "#{prefix}擲出了 #{dice.result} (#{dice.explain_result})"
      }
    end
  end

end

Cabot::Core::CommandProcessor.register_rule(Dice::PATTERN, Dice)
