require 'rubygems'
require 'sinatra'
require 'json'

root = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift root
$LOAD_PATH.unshift File.join(root, 'lib')

set :root, root
set :run, :false
set :lx_dir, '/var/lx'
set :render_dir, '/mnt/render'

require 'main'
run Sinatra::Application
