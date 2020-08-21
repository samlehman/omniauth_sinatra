require 'rubygems'
require 'bundler'
require "bundler/setup"

Bundler.require

$stdout.sync = true

require './my_sinatra_app'
run MySinatraApp
