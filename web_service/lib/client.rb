module RenderFarm
  class Client

    include MongoMapper::Document

    key :email, String, :required => true, :allow_blank => false
    key :password, String, :required => true, :allow_blank => false
    key :created, Time, :required => true, :allow_blank => false
    key :render_time, Integer, :required => true, :allow_blank => false
    key :tasks, Array, :required => true, :allow_blank => false

    email_format = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

    validates_format_of :email, :with => email_format
    validates_length_of :password, :within => 6..20
    validates_numericality_of :render_time, :only_integer => true

    def initialize
    end

  end
end
