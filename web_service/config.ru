require 'rubygems'
require 'sinatra'
require 'json'

root = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift root
$LOAD_PATH.unshift File.join(root, 'lib')

set :root, root
set :run, :false

require 'main'
run Sinatra.application
