require_relative "spec_helper"

module Cct
  describe LocalUser do
    attr_reader :user

    before do
      @user = LocalUser.new
    end

    describe "#login" do
      it "returns user system login as string" do
        expect(user.login).not_to be_empty
        expect(user.login).to be_a(String)
      end
    end

    describe "#name" do
      it "returns user system name as string" do
        expect(user.name).not_to be_empty
        expect(user.name).to be_a(String)
      end
    end

    describe "#homedir" do
      pending
    end

    describe "#uid" do
      pending
    end

    describe "#gid" do
      pending
    end

    describe "#root?" do
      it "returns true or false" do
        expect(user.root?).not_to be_nil
        expect(user.root?).to be_boolean
      end
    end
  end
end
