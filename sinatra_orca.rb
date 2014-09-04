require 'pp'
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
  :post=>"8000",
  :user=>"ormaster",
  :passwd=>"ormaster123"
}

get '/' do
  @patiens=list_patiens(HOST,PORT,USER,PASSWD)
  haml :index
end
