module SendFileWithRange
  module ControllerExtension

    def send_file(path, options = {})
      if options[:range]
        send_file_with_range(path, options)
      else
        super path, options
      end
    end

    def send_file_with_range(path, options = {})
      if File.exist?(path)
        file_size = File.size(path)
        begin_point = 0
        end_point = file_size - 1
        status = 200
        if request.headers['range']
          status = 206
          if request.headers['range'] =~ /bytes\=(\d+)\-(\d*)/
            begin_point = $1.to_i
            end_point = $2.to_i if $2.present?
          end
        end
        content_length = end_point - begin_point + 1
        response.header['Content-Range'] = "bytes #{begin_point}-#{end_point}/#{file_size}"
        response.header['Content-Length'] = content_length.to_s
        response.header['Accept-Ranges'] = 'bytes'
        send_data IO.binread(path, content_length, begin_point), options.merge(:status => status)
      else
        raise ActionController::MissingFile, "Cannot read file #{path}"
      end
    end

  end
end
