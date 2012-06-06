require 'rubygems'
require 'bundler/setup'
require 'heroku'
require 'sinatra'
require 'haml'
require "sass/plugin/rack"
require 'mongo'
require 'pony'
require File.join(File.dirname(__FILE__), *%w[lib server])

RichardStallmanVisitsForward.new