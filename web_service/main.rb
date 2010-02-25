require 'rubygems'
require 'sinatra'
require 'mongo'

root = File.dirname(File.dirname(File.expand_path(__FILE__)))
$: << File.join(root, 'lib')

# Task list
get '/' do
  require 'task_list'
  TaskList.new.response
end

# API
get %r{^/api/([\w]+)(?:/([\w]+))?/?$} do |collection, element|
  require 'api'
  API.new(collection, element).response
end