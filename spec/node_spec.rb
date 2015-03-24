require_relative "spec_helper"
require "cct/cukes/world"

module Cct
  describe Node do
    attr_reader :node

    before do
      expect {
        @node = Node.new(
          name: "test",
          ip: "127.0.0.1",
          user: "test",
          password: "test+password",
          timeout: 2
        )
      }.not_to raise_error
    end

    describe "#admin?" do
      it "is not an admin node" do
        expect(node.admin?).to eq(false)
      end
    end

    describe "#local?" do
      it "is not a local node" do
        expect(node.local?).to eq(false)
      end
    end

    describe "#remote?" do
      it "is a remote node" do
        expect(node.remote?).to eq(true)
      end
    end

    describe "#connected?" do
      it "is not connected automatically" do
        expect(node.connected?).to eq(false)
      end
    end
  end
end
