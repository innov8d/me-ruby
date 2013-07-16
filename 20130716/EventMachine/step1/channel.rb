#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'

EM.run do
	c = EM::Channel.new

	EM.defer do
		puts "[#{Thread.current.object_id}] First defer"
		c.subscribe { |m| puts "[#{Thread.current.object_id}] 1: #{m}" }
		sleep(3)
		c << "Defer 1"
	end

	EM.defer do
		puts "[#{Thread.current.object_id}] Second defer"
		sid = c.subscribe { |m| puts "[#{Thread.current.object_id}] 2: #{m}" }
		sleep(2)
		c.unsubscribe(sid)
	end

	EM.add_periodic_timer(1) do
		puts "[#{Thread.current.object_id}] Periodic timer"
		c << "Hello"
	end
end
