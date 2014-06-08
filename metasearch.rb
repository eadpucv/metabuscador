#!/usr/bin/env ruby
# encoding: UTF-8
require "bundler/setup"
require 'rubygems' 
require 'sinatra'
require 'httparty'
require 'json'
require './cas.rb'

use Rack::Session::Cookie, :secret => '3c053cb6dc88e281b96ed0b8d18c69ee'
helpers CasHelpers

before do
	process_cas_login(request, session)
end

get '/metasearch' do
		rows = 20
		@previus_start = 0
		@next_start = 0

		if params[:start] 
			start = params[:start].to_i
		else 
			start = 0
		end

		## genero las query
		query = HTTParty.post("http://190.208.62.202:9090/services/rest/index/ead_index/search/field/search?login=rodrigomt&key=b57e300b028e2ea64dd62084eddbeafb",
			:body => {  
				:query => params[:query], 
            :start => start, 
				:rows => rows, 
				:lang => 'SPANISH', 
				:operator => 'AND'
         }.to_json,
    		:headers => { 'Content-Type' => 'application/json' } )

		@results = JSON.parse(query.body.to_s)
		
		## seteo las variables

		@previus_start = start - rows
		@next_start = start + rows

		if @next_start >= @results["numFound"].to_i
			@next_start = nil
		end

		if @previus_start < 0
			@previus_start = nil
		end	


	erb :layout
end

get '/logout' do
	session.clear
	cas_logout()
end

get '/login' do
	if session[:cas_ticket] && !session[:cas_ticket].empty?
   	redirect '/metasearch'
   else
   	require_authorization(request, session)
   end
end