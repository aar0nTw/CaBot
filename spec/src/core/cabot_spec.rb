require 'spec_helper'
require 'json'

describe Cabot do
  FAKE_KEY = {
    channel_secret: 'channel_secret',
    channel_token: 'channel_token',
    reply_token: 'nHuyWiB7yP5Zw52FIkcQobQuGDXCTA'
  }

  context Cabot::VERSION do
    it "has version number" do
      expect(Cabot::VERSION).not_to be nil
    end
  end

  context Cabot::Cabot do
    before {
      @cabot = Cabot::Cabot.new FAKE_KEY[:channel_secret], FAKE_KEY[:channel_token]
      @request = double()
      @request.stub(:env) { {'HTTP_X_LINE_SIGNATURE': 'line_signature'} }
      @request.stub_chain(:body, :read).and_return <<"EOS"
{
  "events": [
      {
        "replyToken": "#{FAKE_KEY[:reply_token]}",
        "type": "message",
        "timestamp": 1462629479859,
        "source": {
             "type": "user",
             "userId": "U206d25c2ea6bd87c17655609a1c37cb8"
         },
         "message": {
             "id": "325708",
             "type": "text",
             "text": "Hello, world"
          }
      }
  ]
    }
EOS
    }

    it "cabot.clinet should be Line::Bot::Client object" do
      expect(@cabot.client).to be_a Line::Bot::Client
    end

    it "cabot.handle should set @reply_token automatically" do
      Line::Bot::Client.any_instance.stub(:validate_signature => true)
      @cabot.handle @request
      expect(@cabot.reply_token).to eq FAKE_KEY[:reply_token]
    end

    it "Signature validation fail should return false" do
      Line::Bot::Client.any_instance.stub(:validate_signature => false)
      expect(@cabot.handle @request).to be false
    end

    it "Send Messages should return true" do
      Line::Bot::Client.any_instance.stub(:reply_message => {})
      expect(@cabot.send_messages({type: 'text', text: 'foo'})).to eq true
    end

    it "Send empty array should return false" do
      Line::Bot::Client.any_instance.stub(:reply_message => {})
      expect(@cabot.send_messages([])).to eq false
    end

    it "cabot.handle should call a CommandProcessor match" do
      Line::Bot::Client.any_instance.stub(:validate_signature => true)
      Line::Bot::Client.any_instance.stub(:reply_message => {})
      allow(Cabot::Core::CommandProcessor).to receive(:match)
      @cabot.handle @request
      expect(Cabot::Core::CommandProcessor).to have_received :match
    end
  end

  context Cabot::Core::CommandProcessor do
    CommandProcessor = Cabot::Core::CommandProcessor
    DUMMY_DATA = {
      regex: /^\/cabot\W\w+/,
      msg: "Hello World",
      send_text: "/cabot hi",
      send_not_match_text: "/gh"
    }
    before {
      handler = Object
      handler.any_instance.stub(:reply) {|text| msg + DUMMY_DATA[:send_text] }
      handler.any_instance.stub(:msg) { DUMMY_DATA[:msg] }
      CommandProcessor.register_rule DUMMY_DATA[:regex], handler
    }
    it "CommandProcessor should have a class method: rule_hash" do
      expect(CommandProcessor).to respond_to :rules_hash
    end
    it "CommandProcessor should have a class method: register_rule" do
      expect(CommandProcessor).to respond_to :register_rule
    end

    it "When Register a rule, then rule_hash length should add 1" do
      expect(CommandProcessor.rules_hash.length).to eq 2
    end

    it "When Register a rule, then rule_hash length should add rule " do
      expect(CommandProcessor.rules_hash.has_key? DUMMY_DATA[:regex]).to eq true
    end

    it "When Register a rule, then rule_hash[key] should be a method name reply" do
      expect(CommandProcessor.rules_hash[DUMMY_DATA[:regex]].name).to eq :reply
    end

    it "When match a rule, show return method result" do
      expect(CommandProcessor.match(DUMMY_DATA[:send_text])).to eq DUMMY_DATA[:msg] + DUMMY_DATA[:send_text]
    end

    it "When not match any rule, return []" do
      expect(CommandProcessor.match(DUMMY_DATA[:send_not_match_text])).to eq []
    end

  end

end
