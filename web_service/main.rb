require 'rubygems'
require 'sinatra'
require 'mongo'

# Task list
get '/' do
  @posts = [] # Temporary
  erb :index
end

# API
get %r{^/api/([\w]+)(?:/([\w]+))?/?$} do |collection, element|
  # Relax
end
