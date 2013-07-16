#!/usr/bin/env ruby

require 'rubygems'
require 'redis'
require 'eventmachine'

@running = true
@redis = Redis.new
@c = EM::Channel.new

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
		@c << message
	end
end

def process_message(msg)
	puts " > [#{Thread.current.object_id}] Processing message: #{msg}"
	sleep(10)
	puts " > [#{Thread.current.object_id}] Done processing message: #{msg}"
end

def process_message2(msg)
	puts " >> [#{Thread.current.object_id}] Alternate processing message: #{msg}"
	sleep(15)
	puts " >> [#{Thread.current.object_id}] Done alternate processing message: #{msg}"
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

	@c.subscribe { |msg| EM.defer { process_message(msg) } }
	@c.subscribe { |msg| EM.defer { process_message2(msg) } }

	EM.defer { tick }
end

