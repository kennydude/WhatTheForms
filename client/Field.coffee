class @Field extends @Box
	validate : () ->
		val = @template.value
		error = []

		async.each @validators, (validator, n) ->
			validator val, (err) ->
				if err
					error.push err
				n()
		, () =>
			error = error.join("\n")
			if error == ""
				error = null
			console.log error, @
			@template.error = error

	go: (wrap, data) ->
		@template = new tpl_basic_field(wrap)
		@template.client = true

		@validators = data.validators

		@template.on "input-changed", () =>
			@validate()
		return @
