# @exclude
@FormElement = require("./Field").FormElement
async = require("async")
# @endexclude

class @Fieldset extends @FormElement
	constructor: () ->
		@items = []

	label : (@_label) ->
		return this
	add : (item) ->
		@items.push(item)

	render : (req, res, form) ->
		sI = 0
		for item in @items
			item.id( @_id + 'si' + sI )
			sI++

		return {
			"type" : "fieldset",
			"fields" : item.render(req, form) for item in @items,
			"data" : {
				"label" : @_label
			}
		}

	# This is the 1 occasion where this is acceptable, because a grouping
	# shouldn't have an error
	do_validation: (req, fn) ->
		errors = {}
		values = {}
		hasErrors = false

		async.each @items, (item, next) ->
			item.do_validation req, (err, val) ->
				if err
					errors[item.id()] = err
					hasErrors = true
				values[item.id()] = val
				console.log item.id(), err, "ERRRRR"
				next()
		, () ->
			if not hasErrors
				errors = null
			fn( errors, values )
