require "integration/support/int_helper"
require "pakyow/support/silenceable"

RSpec.describe "disconnecting a websocket" do
  include Pakyow::Support::Silenceable

  before do
    start_server
  end

  let :client do
    silence_warnings do
      @client = WebSocketClient.create
      # wait for it to connect
      sleep 0.05
    end

    @client
  end

  context "when a `leave` callback is defined" do
    before do
      left = -> (context) { @context = context }
      Pakyow::Realtime::Connection.on :leave do
        left.call(self)
      end

      client
      client.shutdown
      sleep 0.05
    end

    it "invokes the callback" do
      expect(@context).not_to be_nil
    end

    describe "the callback context" do
      it "is a `Pakyow::CallContext` instance" do
        expect(@context).to be_instance_of(Pakyow::CallContext)
      end
    end
  end
end
