#!/usr/bin/env ruby

root = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift File.join(root, '..', 'web_service', 'lib')

require 'rubygems'
require 'mongo_mapper'
require 'task'

include RenderFarm
lx_dir = '/var/lx'
MongoMapper.database = 'renderfarm'

tasks = Task.all(
  :conditions => { :status => [:accepted, :sent, :deployed, :rendered] },
  :order => 'modified asc'
)
accepted = tasks.select { |task| task.status == :accepted }
rendered = tasks.select { |task| task.status == :rendered }
master_node_busy = tasks - accepted - rendered

unless rendered.empty?
  task = rendered.first
  p task.hash
  File.makedirs File.join(lx_dir, task.hash.to_s, 'result') 
  File.copy '/mnt/render/*', File.join(lx_dir, task.hash, 'result')
  File.delete '/mnt/render/*'
  task.status = :completed
  task.save
end

if master_node_busy.empty? and !accepted.empty?
  task = accepted.first
  File.copy File.join(lx_dir, task.hash), '/mnt/render/'
  task.status = :sent
  task.save
end

