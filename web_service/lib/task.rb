module RenderFarm
  class Task

    include MongoMapper::Document

    key :status, Symbol, :required => true, :allow_blank => false
    key :created, Time, :required => true, :allow_blank => false
    key :modified, Time, :required => true, :allow_blank => false
    key :hash, String, :required => true, :allow_blank => false
    key :render_time, Integer, :required => true, :allow_blank => false
    key :render_start, Time

    validates_length_of :hash, :is => 40
    validates_numericality_of :render_time, :only_integer => true

    def initialize(user, file, render_time)
      self.user = user
      self.status = :uploaded
      self.created = Time.new
      self.modified = self.created

      require 'digest/sha1'
      sha1 = Digest::SHA1.new
      open(file, 'rb') do |io|
        until io.eof
          buf = io.readpartial(1024)
          sha1.update(buf)
        end
      end

      self.hash = sha1.hexdigest
      self.render_time = render_time
      self.render_start = nil
    end

  end
end
