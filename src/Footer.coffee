# @exclude
WhatTheClass = require("./WhatTheClass").WhatTheClass
# @endexclude

class @Footer extends WhatTheClass
	render : () ->
		throw new Error("render() is not defined")

class @BasicFooter extends @Footer
	constructor: () ->
		super
		@buttons = []

	clear : () ->
		@buttons = []
		return @

	add : (label, type, cls) ->
		@buttons.push {
			"label" : label,
			"type" : type || "submit",
			"class" : cls || "default"
		}
		return @

	render : () ->
		if @buttons.length == 0
			@add "Submit", "submit", "primary"

		return {
			"type" : "basic",
			"data" : {
				"buttons" : @buttons
			}
		}

###
Charge Money with Stripe

This footer allows you to use Stripe Checkout so you can pay for things
###
class @StripeFooter extends @Footer
	@property "stripeKey", 'pk_test_6pRNASCoBOKtIshFeQd4XMUh'
	@property "testMode", true
	@property "image", 'http://placekitten.com/g/128/128'
	@property "description", "Placeholder"
	@property "title", "My Cat [Placeholder]"
	@property "amount", "100"

	render : () ->
		return {
			"type" : "stripe",
			"data" : @properties()
		}
