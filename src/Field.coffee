# @exclude
WhatTheClass = require("./WhatTheClass").WhatTheClass
async = require("async")
# @endexclude

class @FormElement extends WhatTheClass
	@property "id"

	constructor: () ->
		throw new Error("Abstract class cannot be instantiated")
	# Methods
	render : (req) ->
		throw new Error("render() method is not implemented")

	# DO NOT IMPLEMENT YOURSELF
	do_validation : (req, cb, server_only) ->
		@run_validation req, (err, value) =>
			cb err, value
		, server_only

	run_validation: (req, fn, server_only) ->
		console.log "WARN: run_validation() method is not implemented!"
		fn( new Error("run_validation() method is not implemented"), null )

	script : () ->
		throw new Error("script() method is not implemented")

	extraProps : () -> # Do nothing

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
		if !errMsg
			errMsg = "Not a valid value"

		# What kind of validator are we dealing with
		if validation instanceof RegExp
			@validators.push new Function("value", "next", """
if( #{validation}.test( value ) == true) next(null);
else{ next(#{JSON.stringify(errMsg)}); }
""");
		else if typeof validation == "function"
			@validators.push validation # push function directly!

		return @

	###
	Add Server-side validation
	@param validation function
	###
	validateServer : (validation) ->
		if !@serverValidators
			@serverValidators = []

		@serverValidators.push validation

		return @

	run_validation: (req, fn, server_only) ->
		# Validation for fields
		val = req.body[ @name() ]
		delete req.body[ @name() ] # Remove it!
		error = []

		if !@validators
			@validators = []
		if !@serverValidators
			@serverValidators = []

		if server_only == true
			return @do_server_validation(req, val, fn, error)

		async.each @validators, (validator, n) ->
			validator val, (err) ->
				if err
					error.push err
				n()
		, () =>
			@do_server_validation(req, val, fn, error)

	do_server_validation : (req, val, fn, error) ->
		async.each @serverValidators, (validator, n) ->
			validator val, req, (err) ->
				if err
					error.push err
				n()
		, () ->
			if error.length == 0
				error = null
			else
				error = error.join("<br/>")
			fn error, val

	client : () ->
		if !@validators
			@validators = []
		if !@serverValidators
			@serverValidators = []

		validators = ( (v.toString().replace("function anonymous", "function")) for v in @validators )

		validators = validators.join(",")
		return """{
	"validators" : [ #{validators} ],
	"id" : #{JSON.stringify(@id())},
	"server_validate" : #{@serverValidators.length != 0}
}"""

class @BasicField extends @Field
	constructor: (@_type) ->

	# Properties
	@property "type"
	@property "placeholder", ""
	@property "value"

	templateName : () ->
		return "basic_field"

	render : (req) ->
		return {
			"type" : @templateName(),
			"data" : {
				"type" : @type(),
				"label" : @label(),
				"name" : @name(),
				"placeholder" : @placeholder(),
				"id" : @id() || @name(),
				"value" : @value()
			},
			"id" : @id() || @name(),
			"client" : @client(),
			"script" : @script()
		}

	script : () ->
		return { "require" : "Field", "class" : "Field" }

class @TextField extends @BasicField
	constructor: () -> super "text"
class @PasswordField extends @BasicField
	constructor: () -> super "password"
