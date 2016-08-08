namespace :dev do

  desc 'Run scanner'
  task run: :environment do
    %x(rake db:schema:load && rake db:seed)

    channels = [Channel.vimeo.first]
    channels.each do |ch|
      Updater::Channel.new(ch).start
    end
  end

  desc 'Scan all channels'
  task scan_all_channels: :environment do
    Channel.find_each do |channel|
      Updater::Channel.new(channel).start
    end
  end

end
