class @Field extends @Box
	serverValidation : () ->
		microAjax form.action + "?request=whattheforms&cmd=validate", (text) =>
			@template.loading = false
			try
				d = JSON.parse(text)
				if d.status == "ok"
					if d.error
						@srErr = d.error
					else
						@srErr = null
				else
					@srErr = "Internal Error"
			catch e
				console.log(e)
				@srErr = "Internal Error"
			@renderError()

		, encQS({ "fieldid" : @id, "value" : @template.value })

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
			@clErr = error
			@renderError()

	renderError : () ->
		er = [ @clErr, @srErr ].join("<br/>")
		if er == "<br/>"
			er = null
		@template.error = er

	go: (wrap, data) ->
		@template = new tpl_basic_field(wrap, { "client" : true })

		@validators = data.validators
		@id = data.id
		@vServer = data.server_validate

		@clTimer = null
		@srTimer

		@clErr = null
		@srErr = null

		@template.on "input-changed", () =>
			if @vServer
				@template.loading = true

			if @clTimer
				clearTimeout @clTimer
			@clTimer = setTimeout () =>
				@validate()
			, 100

			if @vServer
				if @slTimer
					clearTimeout @slTimer
				@slTimer = setTimeout () =>
					@serverValidation()
				, 1000
		return @
