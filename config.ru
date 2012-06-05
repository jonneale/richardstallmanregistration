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
require File.join(File.dirname(__FILE__), *%w[lib server])

run RichardStallmanVisitsForward.new