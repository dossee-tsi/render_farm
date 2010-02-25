require 'rubygems'
require 'sinatra'

root = File.dirname(File.dirname(File.expand_path(__FILE__)))
$: << root
$: << File.join(root, 'lib')

set :run, :false

require 'main'
run Sinatra.application
