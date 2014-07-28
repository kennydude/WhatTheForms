WhatTheClass = require("./WhatTheClass").WhatTheClass

class @FormElement extends WhatTheClass
	@property "id"

	constructor: () ->
		throw new Error("Abstract class cannot be instantiated")
	# Methods
	render : () ->
		throw new Error("render() method is not implemented")

	# DO NOT IMPLEMENT YOURSELF
	do_validation : (req, cb) ->
		@run_validation req, (err) =>
			@error = err
			cb err

	run_validation: (req, fn) ->
		console.log "WARN: run_validation() method is not implemented!"
		fn( new Error("run_validation() method is not implemented") )

class @Field extends @FormElement
	# Properties
	@property "name"
	@property "label"

	###
    Add Client-Side validator
    @param validation RegExp/function
	###
	validate : (validation, errMsg) ->
		if !@validators
			@validators = []

		# What kind of validator are we dealing with
		if validation instanceof RegExp
			@validators.push (value, next) ->
				if validation.test value
					next(null) # No Error
				else
					next(errMsg)
		else if typeof validation == "function"
			@validators.push validation # push function directly!

		return @


class @BasicField extends @Field
	constructor: (@_type) ->
		@_placeholder = ""

	# Properties
	@property "type"
	@property "placeholder"

	render : () ->
		return {
			"type" : "basic_field",
			"data" : {
				"type" : @type(),
				"label" : @label(),
				"name" : @name(),
				"placeholder" : @placeholder(),
				"id" : @id() || @name(),
				"error" : @error
			},
			"id" : @id()
		}

class @TextField extends @BasicField
	constructor: () -> super "text"
class @PasswordField extends @BasicField
	constructor: () -> super "password"