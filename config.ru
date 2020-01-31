require 'rubygems'
require 'bundler'
require "bundler/setup"

Bundler.require

require './my_sinatra_app'
run MySinatraApp
