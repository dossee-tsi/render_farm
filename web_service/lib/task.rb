module RenderFarm
  class Task

    include MongoMapper::Document

    key :status, Symbol, :required => true, :allow_blank => false
    key :created, Time, :required => true, :allow_blank => false
    key :modified, Time, :required => true, :allow_blank => false
    key :hash, String, :required => true, :allow_blank => false
    key :render_time, Integer, :required => true, :allow_blank => false
    key :render_start, Time, :required => true, :allow_blank => true

    validates_uniqueness_of :hash
    validates_length_of :hash, :is => 40
    validates_numericality_of :render_time, :only_integer => true

  end
end
