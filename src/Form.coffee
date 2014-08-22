# @exclude
@WhatTheClass = require("./WhatTheClass").WhatTheClass
@BasicFooter = require("./Footer").BasicFooter
@FormRenderers = require("./FormRenderer").FormRenderers
# @endexclude
async = require "async"

class @Form extends @WhatTheClass
	constructor: () ->
		@items = []
		@_attrs = { "folders" : [] }

		@footer(new module.exports.BasicFooter)

	@property "action", null
	@property "name", "frm1"
	@property "footer"

	add: (item) ->
		if item.name?() == "errors"
			throw new Error("errors is not allowed as WhatTheForms uses this already!")
		@items.push(item)

	addTemplateFolder : (folder) ->
		@_attrs.folders.push folder
		return @

	getItemById : (id) ->
		for item in @items
			if item.id() == id
				return item

	###
	Controls the server-side Express route for the form

	Assumes middleware that provides res.error(code, message)

	@param {function} Displays the form
	@param {function} Processes the form (once validated and checked)
	###
	controller : (def_func, view_func, process_func) ->
		if arguments.length == 2
			x = view_func
			view_func = def_func
			process_func = x
			def_func = null

		# I control express routes!
		return (req, res) =>
			if !@action()
				@action req.path

			req.form = @
			render_func = (format) =>
				return @render( format, req.body, req, res )

			if req.query['request'] == "whattheforms"
				switch req.query['cmd']
					when "js" # This is generally for testing
						res.type("js").end( @script( req.query['format'] || "bootstrap" ) )
					when "validate"
						if !req.body['fieldid']
							return res.error 400, "Field was required"

						item = @getItemById(req.body.fieldid)
						if !item
							return res.json {
								"status" : "fail"
							}

						req.body[ item.name() ] = req.body['value']
						item.do_validation req, (err) ->
							return res.json {
								"status" : "ok",
								"error" : err
							}
						, true
						return
					when "method"
						# Custom method
						if !req.query['fieldid']
							return res.error 400, "Field was required"

						item = @getItemById(req.query.fieldid)
						if !item
							return res.json {
								"status" : "fail"
							}

						if def_func != null
							def_func req, res, (r) ->
								req.data = r
								return item.method( req.query.method, req, res )
						else
							return item.method(req.query.method, req, res)
					else
						return res.error 404, "WhatTheForms Method is not available"
			else if req.method == "POST"
				if !req.body
					return res.error 400, "POST Body not provided"

				errors = false
				result = { "errors" : {} }

				req.action = @action()

				preF = []
				if def_func != null
					preF = [
						(cb) ->
							def_func req, res, (r) ->
								result = r
								if !result['errors']
									result['errors'] = {}
								cb()
					]

				async.series preF, () =>
					async.each @items, (item, cb) ->
						item.do_validation req, (err, value) ->
							if err
								errors = true

							if value
								result[item.name()] = value
							result.errors[item.name()] = err

							cb(null)
						, false
					, () ->
						req.body = result
						if not errors
							return process_func(req, res)

						req.has_errors = true
						return view_func(req, res, render_func)
			else if req.method == "GET"
				if def_func != null
					return async.series [
						(cb) ->
							def_func req, res, (result) ->
								req.body = result
								cb()
					], () ->
						return view_func req, res, render_func
				return view_func(req, res, render_func)
			else
				res.error 404, "Unsupported Method"

	###
	Return the HTML of the form
	@param format {str} Template set to use
	@param result {object} optional Result object
	###
	render: (format, result, req, res) ->
		if !format
			format = "default"
		
		if typeof format == "string"
			if module.exports.FormRenderers[format]
				r = new module.exports.FormRenderers[format]()
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
		if typeof format == "string"
			if module.exports.FormRenderers[format]
				r = new module.exports.FormRenderers[format]()
				return r.script(@)
			else
				throw new Error("Form renderer could not be found")
		else
			return format.script(@)
