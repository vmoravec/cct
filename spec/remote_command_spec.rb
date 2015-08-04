require_relative "spec_helper"

module Cct
  describe RemoteCommand do
    attr_reader :command, :options

    before do
      @options = {ip: 'localhost', user: 'test'}
      @command = RemoteCommand.new(options)
    end

    context "Not connected" do
      describe "#connected?" do
        it "should not be connected by default" do
          expect(command.connected?).to eq(false)
        end
      end

      describe "#session" do
        it "has no SSH session created yet" do
          expect(command.session).to eq(nil)
        end
      end
    end

    context "Connected" do
      describe "#connect!" do
        it "creates a new SSH session" do
          expect(Net::SSH).to receive(:start)
          command.connect!
        end
      end

      describe "#exec!" do
        it "executes a command remotely" do
          expect(Net::SSH).to receive(:start).and_return(OpenStruct.new)
          expect(RemoteCommand::Result).to receive(:new).and_return(
            RemoteCommand::Result.new(true, "Success", "", 0, options[:ip])
          )
          command.connect!
          expect(command.session).not_to eq(nil)
          expect(command.exec!("ls").output).to match("Success")
        end
      end
    end
  end
end
