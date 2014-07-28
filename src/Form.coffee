WhatTheClass = require("./WhatTheClass").WhatTheClass
BasicFooter = require("./Footer").BasicFooter

async = require "async"

class @Form extends WhatTheClass
	constructor: () ->
		@items = []

		@footer(new BasicFooter)

	@property "action", null
	@property "name", "frm1"
	@property "footer"

	add: (item) ->
		@items.push(item)

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

			if req.method == "GET"
				if req.query['request'] == "whattheforms"
					# Return view information for validation
					o = { "status" : "ok", "result" : {} }

					for item in @items
						o.result[item._name] = {
							"validators" : validator.toString() for validator in (item.validators || [])
						}

					res.json(o)
				else
					return view_func(req, res)
			else if req.method == "POST"
				if !req.body
					return res.error 400, "POST Body not provided"

				errors = []
				console.log @items
				async.each @items, (item, cb) ->
					console.log "VALIDATE ITEM"
					item.do_validation req, (err) ->
						if(err != null)
							errors.push err
						cb(null)
				, () ->
					console.log "OK"
					if errors.length == 0
						return process_func(req, res)

					req.has_errors = true
					return view_func(req, res)
			else
				res.error 404, "Unsupported Method"

	###
    Return the HTML of the form
    @param format {str} Template set to use
    ###
	render: (format) ->
		# Only include form renders code path if required
		FormRenderers = require("./FormRenderer").renderers
		if typeof format == "string"
			if FormRenderers[format]
				r = new FormRenderers[format]()
				return r.render(@)
			else
				throw new Error("Form renderer could not be found")
		else
			return format.render(@)

	###
    Return the Javascript required to make the form function correctly everywhere,
    and to validate inline!
    @param format {str} Template set to use
	###
	script : (format) ->
		templatesRequired = []



		return ''