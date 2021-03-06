module RenderFarm
  class Task

    include MongoMapper::Document

    key :client_id, ObjectId, :required => true
    key :status, Symbol, :required => true
    key :created, Time, :required => true
    key :modified, Time, :required => true
    key :hash, String, :required => true
    key :render_time, Integer, :required => true
    key :render_start, Time

    validates_uniqueness_of :hash
    validates_length_of :hash, :is => 32
    validates_numericality_of :render_time, :only_integer => true

  end
end
