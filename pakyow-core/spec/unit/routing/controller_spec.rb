RSpec.describe Pakyow::Controller do
  let :env do
    {}
  end

  let :app do
    klass = Class.new(Pakyow::App) do
      # don't freeze for these tests, because if we do
      # we won't be able to attach method spies
      def freeze; end
    end

    klass.new(:test, builder: Rack::Builder.new)
  end

  let :request do
    Pakyow::Request.new({})
  end

  let :response do
    Pakyow::Response.new
  end

  let :call_state do
    Pakyow::Call.new(app, request, response)
  end

  let :controller do
    Pakyow::Controller.new(call_state)
  end

  before do
    class Pakyow::Paths
      # don't freeze for these tests, because if we do
      # we won't be able to attach method spies
      def freeze; end
    end
  end

  after do
    class Pakyow::Paths
      remove_method(:freeze)
    end
  end

  it "includes helpers" do
    expect(controller.class.ancestors).to include(Pakyow::Helpers)
  end

  describe ".method_missing" do
    context "when a template is available" do
      before do
        Pakyow::Controller.template(:foo) do; end
      end

      it "expands the template" do
        expect(Pakyow::Controller).to receive(:expand).with(:foo, {})
        Pakyow::Controller.foo
      end
    end

    context "when a template is unavailable" do
      it "fails" do
        expect { Pakyow::Controller.bar }.to raise_error(NoMethodError)
      end
    end
  end

  describe ".respond_to_missing?" do
    context "when a template is available" do
      before do
        Pakyow::Controller.template(:foo) do; end
      end

      it "returns true" do
        expect(Pakyow::Controller.respond_to_missing?(:foo)).to eq(true)
      end
    end

    context "when a template is unavailable" do
      it "returns false" do
        expect(Pakyow::Controller.respond_to_missing?(:bar)).to eq(false)
      end
    end
  end

  describe "#initialize" do
    it "exposes call state properly" do
      expect(controller.instance_variable_get(:@__state)).to eq(call_state)
    end
  end

  describe ".call" do
    it "tries routing each controller"

    context "when routed" do
      it "marks call state as processed"
    end

    context "when not routed" do
      it "does not mark call state as routed"
    end
  end
end
