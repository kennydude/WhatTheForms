class @Field extends @Box
	validate : () ->
		val = @template.value
		error = []

		async.each @validators, (validator, n) =>
			validator val, (err) ->
				if err
					error.push err
				n()
			, @id
		, () =>
			error = error.join("<br/>")
			if error == ""
				error = null
			@template.error = error

	go: (wrap, data) ->
		@template = new tpl_basic_field(wrap)
		@template.client = true

		@validators = data.validators
		@id = data.id
		@timer = null

		@template.on "input-changed", () =>
			if @timer
				clearTimeout @timer
			@timer = setTimeout () =>
				@validate()
			, 500
		return @
