require 'rubygems'
require 'bundler/setup'
require 'heroku'
require 'sinatra'
require 'haml'
require 'sass'
require 'redis'
require "sass/plugin/rack"
require "json"
require 'mongo'
require 'pony'
require 'resque'
require 'resque/server'
require File.join(File.dirname(__FILE__), *%w[lib server])
require File.join(File.dirname(__FILE__), *%w[lib email])


run Rack::URLMap.new \
  "/"       => RichardStallmanVisitsForward.new,
  "/resque" => Resque::Server.new