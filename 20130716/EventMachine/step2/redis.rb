#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'

@running = true

def tick
	while(@running) do
		puts " - [#{Thread.current.object_id}] tick"
		sleep(1)
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

	EM.defer { tick }
end

