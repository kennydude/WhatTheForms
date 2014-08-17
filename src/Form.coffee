WhatTheClass = require("./WhatTheClass").WhatTheClass
BasicFooter = require("./Footer").BasicFooter

async = require "async"

class @Form extends WhatTheClass
	constructor: () ->
		@items = []
		@_attrs = { "folders" : [] }

		@footer(new BasicFooter)

	@property "action", null
	@property "name", "frm1"
	@property "footer"

	add: (item) ->
		@items.push(item)

	addTemplateFolder : (folder) ->
		@_attrs.folders.push folder
		return @

	###
    Controls the server-side Express route for the form

    Assumes middleware that provides res.error(code, message)

    @param {function} Displays the form
    @param {function} Processes the form (once validated and checked)
	###
	controller : (view_func, process_func) ->
		# I control express routes!
		return (req, res) =>
			req.form = @

			if req.query['request'] == "whattheforms"
				switch req.query['cmd']
					when "js" # This is generally for testing
						res.type("js").end( @script( req.query['format'] || "bootstrap" ) )
					when "validate"
						if !req.body['fieldid']
							return res.error 400, "Field was required"
						for item in @items
							if item.id() == req.body.fieldid
								req.body[ item.name() ] = req.body['value']
								item.do_validation req, (err) ->
									return res.json {
										"status" : "ok",
										"error" : err
									}
								, true
								return
						return res.json {
							"status" : "fail"
						}
					else
						return res.error 404, "WhatTheForms Method is not available"
			else if req.method == "POST"
				if !req.body
					return res.error 400, "POST Body not provided"

				errors = false
				console.log @items
				result = { "errors" : {} }

				req.action = @action()

				async.each @items, (item, cb) ->
					item.do_validation req, (err, value) ->
						if(err)
							errors = true

						result[item.id()] = value
						result.errors[item.id()] = err

						cb(null)
					, false
				, () ->
					console.log "validation result", errors
					req.body = result
					if not errors
						return process_func(req, res)

					req.has_errors = true
					return view_func(req, res)
			else if req.method == "GET"
				return view_func(req, res)
			else
				res.error 404, "Unsupported Method"

	###
    Return the HTML of the form
    @param format {str} Template set to use
	@param result {object} optional Result object
    ###
	render: (format, result, req, res) ->
		# Only include form renders code path if required
		FormRenderers = require("./FormRenderer").renderers

		if format == null
			format = "default"

		if typeof format == "string"
			if FormRenderers[format]
				r = new FormRenderers[format]()
				return r.render @, result, req, res, @_attrs
			else
				throw new Error("Form renderer could not be found")
		else
			return format.render @, result, req, res, @_attrs

	###
    Return the Javascript required to make the form function correctly everywhere,
    and to validate inline!
    @param format {str} Template set to use
	###
	script : (format) ->
		# Only include form renders code path if required
		FormRenderers = require("./FormRenderer").renderers
		if typeof format == "string"
			if FormRenderers[format]
				r = new FormRenderers[format]()
				return r.script(@)
			else
				throw new Error("Form renderer could not be found")
		else
			return format.script(@)
