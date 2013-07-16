#!/usr/bin/env ruby

require 'rubygems'
require 'redis'
require 'eventmachine'

@running = true
@redis = Redis.new

def tick
	while(@running) do
		puts " - [#{Thread.current.object_id}] tick"
		sleep(1)
	end
end

def check_queue
	while (@running) do
		puts " * [#{Thread.current.object_id}] Checking queue."
		message = @redis.blpop('queue')
		puts " * [#{Thread.current.object_id}] Rcvd #{message}, adding to processing queue."
	end
end

def shutdown
	puts " ! [#{Thread.current.object_id}] Shutting down."
	EM.stop
	@running = false
end

EM.run do
	puts " ! [#{Thread.current.object_id}] Starting up."

	Signal.trap('INT')  { shutdown }
	Signal.trap('TERM') { shutdown }

	EM.defer { check_queue }

	EM.defer { tick }
end

