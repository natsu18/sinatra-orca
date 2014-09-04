#!/usr/bin/ruby
#-*-coding:utf-8-*-
$:.unshift File.dirname(__FILE__)

require 'uri'
require 'net/http'
require 'crack'
require 'crack/xml'
require 'sinatra'
require 'haml'
require 'orca_api'

set :bind,'0.0.0.0'
set :public_folder, File.dirname(__FILE__)+'/static'

Net::HTTP.version_1_2

opt={
  :host=>"192.168.4.123",
  :port=>"8000",
  :user=>"ormaster",
  :passwd=>"ormaster123"
}

get '/' do
  @patients=list_patients(opt)
  haml :index
end

get '/register' do
  haml :register
end

post '/register' do
  @patient=params
  @id,@error=register_patient(opt,@patient)
  if @error
    haml:register
  else
    haml:register_result
  end
end

get '/delete' do
  pp params
  @patient=params
  haml:delete
end

post '/delete' do
  @params=params
  @id,@error=delete_patient(opt,@params)
  redirect to '/'
end

