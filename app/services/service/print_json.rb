module Service
  class PrintJSON
    def self.save_json_to_file(hash, filename)
      hash = JSON.pretty_generate hash
      path = Rails.root.join('app', 'services', "#{filename}.json").to_s
      File.open(path, 'w') { |file| file.write hash }
    end
  end
  end