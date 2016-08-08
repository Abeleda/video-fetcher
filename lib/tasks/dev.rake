namespace :dev do

  desc 'Scan all channels'
  task scan_all_channels: :environment do
    FetchManager.new(Channel.all).scan
  end

end
