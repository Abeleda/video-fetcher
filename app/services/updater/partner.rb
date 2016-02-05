module Updater
  class Partner

    def initialize(partner)
      @partner = partner
    end

    def start
      @partner.channels.each do |channel|
        Updater::Channel.new(channel).start
      end
    end

  end
end