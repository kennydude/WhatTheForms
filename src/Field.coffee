WhatTheClass = require("./WhatTheClass").WhatTheClass
async = require("async")

class @FormElement extends WhatTheClass
	@property "id"

	constructor: () ->
		throw new Error("Abstract class cannot be instantiated")
	# Methods
	render : () ->
		throw new Error("render() method is not implemented")

	# DO NOT IMPLEMENT YOURSELF
	do_validation : (req, cb) ->
		@run_validation req, (err, value) =>
			cb err || null, value

	run_validation: (req, fn) ->
		console.log "WARN: run_validation() method is not implemented!"
		fn( new Error("run_validation() method is not implemented"), null )

	clientGo : (@element) ->
		throw new Error("clientGo() method is not implemented")

	typeName : () ->
		throw new Error("typeName() method is not implemented")

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
else{ next("#{errMsg}"); }
""");
		else if typeof validation == "function"
			@validators.push validation # push function directly!

		return @

	run_validation: (req, fn) ->
		# Validation for fields
		val = req.body[ @name() ]
		delete req.body[ @name() ] # Remove it!
		error = []

		if !@validators
			@validators = []

		async.each @validators, (validator, n) ->
			validator val, (err) ->
				if err
					error.push err
				n()
		, () ->
			error = error.join("\n")
			if error == ""
				error = null
			fn error, val

	clientValidationValues : () ->
		throw new Error("clientValidationValues() is not implemented")

	clientRender : () ->
		# Render itself
		r = @render()
		# Validation!
		@do_validation {"body" : @clientValidationValues() }, (err) =>
			r.data.error = err
			r.data['client'] = 1

			console.log r
			@element.innerHTML = swig.run(templates[r.type], r.data)
			@clientGo(@element)

	extraProps : () ->
		return {
			"validators" : "[" + ("#{v}" for v in @validators).join(",") + "]"
		}
	client : () ->
		validators = ("#{v}" for v in @validators).join(",")
		return """{
	"validators" : [ #{validators} ]
}"""

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
				"id" : @id() || @name()
			},
			"id" : @id() || @name(),
			"client" : @client(),
			"script" : @script()
		}

	typeName : () ->
		return "basic_field"

	script : () ->
		return { "require" : "Field", "class" : "Field" }

	clientValidationValues : () ->
		r = {}
		r[@name()] = @value()
		return r

	clientGo : (@element) ->
		@value = () -> # Override property
			return @input.value

		@input = @element.getElementsByTagName("input")[0]
		@input.addEventListener "blur", () =>
			@clientRender()

		return @

class @TextField extends @BasicField
	constructor: () -> super "text"
class @PasswordField extends @BasicField
	constructor: () -> super "password"
