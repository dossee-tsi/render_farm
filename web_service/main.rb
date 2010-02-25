require 'rubygems'
require 'sinatra'
require 'mongo'

root = File.dirname(File.dirname(File.expand_path(__FILE__)))
$: << File.join(root, 'lib')

# Task list
get '/' do
  @posts = [] # Temporary
  erb :index
end

# API
get %r{^/api/([\w]+)(?:/([\w]+))?/?$} do |collection, element|
  # Relax
end
