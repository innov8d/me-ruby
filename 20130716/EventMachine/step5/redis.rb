#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'
require 'redis'
#require 'em-hiredis'
require 'em-synchrony'

@running = true
@c = EM::Channel.new
@redis = nil

def tick
	while(@running) do
		puts " - [#{Thread.current.object_id}] tick"
		EM::Synchrony.sleep(1)
	end
end

def check_queue

	f = Fiber.new do
		message = @redis.lpop('queue')

		if message
			puts " * [#{Thread.current.object_id}] Rcvd #{message}, adding to processing queue."
			@c << message
		else
			EM::Synchrony.sleep(1)
		end

		EM.next_tick { check_queue }
	end

	f.resume
end

def process_message(msg)
	f = Fiber.new do
		puts " > [#{Thread.current.object_id}] Processing message: #{msg}"
		EM::Synchrony.sleep(10)
		puts " > [#{Thread.current.object_id}] Done processing message: #{msg}"
	end

	f.resume
end

def process_message2(msg)
	f = Fiber.new do
		puts " >> [#{Thread.current.object_id}] Alternate processing message: #{msg}"
		EM::Synchrony.sleep(15)
		puts " >> [#{Thread.current.object_id}] Done alternate processing message: #{msg}"
	end

	f.resume
end

def shutdown
	puts " ! [#{Thread.current.object_id}] Shutting down."
	EM.stop
	@running = false
end

EM.synchrony do
	@redis = Redis.new

	puts " ! [#{Thread.current.object_id}] Starting up."

	Signal.trap('INT')  { shutdown }
	Signal.trap('TERM') { shutdown }

	check_queue

	@c.subscribe { |msg| process_message(msg) }
	@c.subscribe { |msg| process_message2(msg) }

	tick
end

