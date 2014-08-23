# @exclude
fls = require "./Field"
@BasicField = fls.BasicField
# @endexclude

## More fields!

class @StaticField extends @BasicField
    constructor: () -> super
    templateName : () ->
        return "static_field"
    client: () -> return null
    script: () -> return null
    run_validation: (req, fn, server_only) ->
        fn null

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

class @TextAreaField extends @BasicField
    templateName: () ->
        return "text_area"
    @property "rows"
    @property "cols"

    render: (req, res, form) ->
        d = super req, res, form
        d.data['rows'] = @rows()
        d.data['cols'] = @cols()
        return d

class @CheckboxField extends @BasicField
    templateName: () ->
        return "checkbox_field"

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
        d = super req, res, form

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

"""
List of stuff that can do everything except Updating individual items
"""
class @CRDListField extends @BasicField
    templateName: () ->
        return "crd_list"

    @property "capabilitiesMethod", () ->
        return ["delete", "add", "read"]
    @property "deleteMethod"
    @property "addMethod"

    render: (req, res, form) ->
        d = super req, res, form

        capabilities = @capabilitiesMethod()(req)
        for capability in capabilities
            d.data["can_#{capability}"] = true

        return d

    method: (methodName, req, res) ->
        capabilities = @capabilitiesMethod()(req)
        if capabilities.indexOf( methodName ) == -1
            return res.error(401, "Unauthorized", { "err" : "cap-not-inc" })

        switch methodName
            when "delete"
                console.log "DELETE"
                @deleteMethod()( req.body[ "method_value" ], req['data'], (err) ->
                    console.log "done"
                    if err
                        return res.error(503, err)
                    return res.redirect req.path
                , req)
            else
                return res.error(400, "Invalid method requested")
