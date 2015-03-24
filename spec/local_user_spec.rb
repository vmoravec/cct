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
      it "returns the existing path to the homedir" do
        expect(File.exist?(user.homedir)).to eq(true)
      end
    end

    describe "#uid" do
      it "returns the user id" do
        expect(user.uid).not_to be(nil)
        expect(user.uid).to be_a(Integer)
      end
    end

    describe "#gid" do
      it "returns the user group id" do
        expect(user.gid).not_to be(nil)
        expect(user.gid).to be_a(Integer)
      end
    end

    describe "#root?" do
      it "returns true or false" do
        expect(user.root?).not_to be_nil
        expect(user.root?).to be_boolean
      end
    end
  end
end
