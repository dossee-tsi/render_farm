module RenderFarm

  helpers do

    def file_hash(file)
      md5 = Digest::MD5.new
      until file.eof
        buf = file.readpartial(1024)
        md5.update(buf)
      end
      md5.hexdigest
    end

    def create_task(tempfile, render_time)
      now = Time.new
      hash = file_hash(tempfile)
      Task.new({
        :client_id => @client.id,
        :status => :uploaded,
        :created => now,
        :modified => now,
        :hash => hash,
        :render_time => render_time,
        :render_start => nil
      })
    end

    def zip_base_path(zip)
      zip.each do |zipped_file|
        if zipped_file.name =~ /\.lxs$/
          if (dirname = File.dirname(zipped_file.name)) != '.'
            zipped_file.name = File.join(dirname, options.scene_file)
            return dirname
          else
            zipped_file.name = options.scene_file
            return ''
          end
        end
      end
      nil
    end

    def zip_extract(zip, base_path, destination)
      zip.each do |zipped_file|
        next if zipped_file.directory? || (zipped_file.name[0, base_path.length] != base_path)
        path = File.join(destination, zipped_file.name[base_path.length..-1])
        begin
          FileUtils.mkdir_p(File.dirname(path))
          zip.extract(zipped_file, path) unless File.exist?(path)
        rescue
          return false
        end
      end
      true
    end

    def unzip_lx(file, destination, render_time)
      Zip::ZipFile.open(file) do |zip|
        base_path = zip_base_path(zip)
        return false unless base_path
        if zip_extract(zip, base_path, destination)
          begin
            scene_file = File.join(destination, options.scene_file)
            lines = IO.readlines(scene_file)
            halttime = %r{^(\s*"integer halttime"\s+\[)(\d+)(\]\s*)$}
            lines.each do |line|
              if line =~ halttime
                line.sub!(halttime, '\1' + render_time.to_s  + '\3')
                break
              end
            end
            File.new(scene_file, 'w').write(lines.join)
            return true
          rescue
            return false
          end
        end
      end
      false
    end

  end

  # Routes

  post '/tasks' do
    client_area!
    requires params, :file, :render_time
    tempfile = params[:file][:tempfile]
    throw_bad_request unless tempfile

    # Create task
    task = create_task(tempfile, params[:render_time])
    throw_bad_request unless task.save
    @client.tasks += [task.id]
    unless @client.save
      task.destroy
      throw_bad_request
    end

    # Async extraction
    Thread.new do
      destination = File.join(options.lx_dir, task.hash)
      unless unzip_lx(tempfile.path, destination, task.render_time)
        task.status = :rejected
        task.save
        FileUtils.rm_r(destination) if File.exists? destination
      end
    end

    # Return result
    json({
      :status => task.status,
      :created => task.created,
      :modified => task.modified,
      :hash => task.hash,
      :render_time => task.render_time,
      :render_start => task.render_start
    })
  end

end
