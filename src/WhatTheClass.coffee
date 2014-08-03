# What The Class??

class @WhatTheClass
	constructor : (args = {}) ->
		for key, value of args
			@[key]? value

	@property : (name, def = null) ->
		@prototype[name] = () ->
			if arguments.length == 1
				@["_" + name] = arguments[0]
				return @
			else
				return @["_" + name]
		@prototype["_" + name] = def

		if !@prototype._props
			@prototype._props = []
		@prototype._props.push name

	properties : () ->
		if arguments.length == 1
			props = arguments[0]
			for key, value of props
				@[key](value)
			return @
		else
			ret = {}
			for prop in @_props
				ret[prop] = @[prop]()
			return ret