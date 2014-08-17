fls = require "./Field"
@BasicField = fls.BasicField

## More fields!

class @StaticField extends @BasicField
    constructor: () -> super
    templateName : () ->
        return "static_field"

class @SelectField extends @BasicField
    constructor: () ->
        super
        @options = {}

    templateName : () ->
        return "select_field"

    option : (name, value) ->
        @options[name] = value
        return @

    render : () ->
        d = super
        d.data['options'] = @options
        return d

class @HiddenField extends @BasicField
    constructor: () ->
        super "hidden"
    templateName : () ->
        return "hidden_field"
    client : () ->
        return null
    script: () ->
        return null

class @CSRFField extends @HiddenField
    constructor: () ->
        super
        @name "csrf-token"
    run_validation: (req, fn, server_only) ->
        val = req.body[ @name() ]
        delete req.body[ @name() ] # Remove it!

        if val != req.signedCookies[ new Buffer(req.action + "--csrf").toString("hex") ]
            return fn "CSRF Token is not valid"
        fn null

    render : (req, res, form) ->
        d = super req, form

        if !req
            return d

        buf = require('crypto').randomBytes(48)
        token = buf.toString('hex')

        if !req['signedCookies']
            throw new Error("No req.signedCookies which is required for CSRF protection")

        d.data.value = token
        # TODO: have a form config for "test mode" aka no https requirement
        res.cookie(new Buffer(form.action() + "--csrf").toString("hex"), token, { signed: true })

        return d
