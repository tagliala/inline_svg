module InlineSvg
  class WebpackAssetFinder
    def self.find_asset(filename)
      new(filename)
    end

    def initialize(filename)
      @filename = filename
      manifest_lookup = wrapper.manifest.lookup(@filename)
      @asset_path =  manifest_lookup.present? ? URI(manifest_lookup).path : ""
    end

    def pathname
      return if @asset_path.blank?

      if wrapper.dev_server.running?
        dev_server_asset(@asset_path)
      elsif wrapper.config.public_path.present?
        File.join(wrapper.config.public_path, @asset_path)
      end
    end

    private

    def wrapper
      @wrapper ||=
        if defined?(::Shakapacker)
          ::Shakapacker
        else
          ::Webpacker
        end
    end

    def dev_server_asset(file_path)
      asset = fetch_from_dev_server(file_path)

      begin
        Tempfile.new(file_path).tap do |file|
          file.binmode
          file.write(asset)
          file.rewind
        end
      rescue StandardError => e
        Rails.logger.error "[inline_svg] Error creating tempfile for #{@filename}: #{e}"
        raise
      end
    end

    def fetch_from_dev_server(file_path)
      http = Net::HTTP.new(wrapper.dev_server.host, wrapper.dev_server.port)
      http.use_ssl = wrapper.dev_server.protocol == "https"
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      http.request(Net::HTTP::Get.new(file_path)).body
    rescue StandardError => e
      Rails.logger.error "[inline_svg] Error fetching #{@filename} from webpack-dev-server: #{e}"
      raise
    end
  end
end
