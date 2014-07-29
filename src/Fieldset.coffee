FormElement = require("./Field").FormElement
async = require("async")

class @Fieldset extends FormElement
	constructor: () ->
		@items = []

	label : (@_label) ->
		return this
	add : (item) ->
		@items.push(item)

	render : () ->
		sI = 0
		for item in @items
			item.id( @_id + 'si' + sI )
			sI++

		return {
			"type" : "fieldset",
			"fields" : item.render() for item in @items,
			"data" : {
				"label" : @_label
			}
		}

	# This is the 1 occasion where this is acceptable, because a grouping
	# shouldn't have an error
	do_validation: (req, fn) ->
		errors = false
		async.each @items, (item, next) ->
			item.do_validation req, (err) ->
				if err
					errors = true
				next()
		, () ->
			fn( errors == true ? "InternalFieldsetError" : null )