@renderers = {}

class FormRenderer
	constructor: () ->
		throw new Error("Abstract class cannot be initialized")
	render: (form) ->
		throw new Error("render(form) is not implemented")

# Included Classes

ent = require("ent")
fs = require("fs")

swig = require('swig')
fallbackswigloader = require("fallbackswigloader")
if process?.env?.DEBUG? # Turn off template cache when in debug mode!
	swig.setDefaults({ cache: false })

renderTemplate = (renderer, template_name, data) ->
	swig.setDefaults {
		loader : fallbackswigloader([
			"templates/#{renderer}",
			"templates/default"
		])
	}
	return swig.renderFile("#{template_name}.html", data)

class BasicFormRenderer extends FormRenderer
	render: (form) ->
		action = ent.encode form.action()
		o = []
		fldId = 0

		for item in form.items
			item.id(form._name + "fld" + fldId)

			vend = item.render(@format)
			if vend.type == "fieldset" # Fieldsets are handled differently at the moment
				if !vend['data']
					vend.data = {}

				vend.data.fields = []
				for field in vend.fields
					vend.data.fields.push {
						"id" : field.id.toString(),
						"value" : renderTemplate(@format, field.type, field.data)
					}
					fldId++

			o.push {
				"id" : item.id()
				"value" : renderTemplate(@format, vend.type, vend.data)
			}
			fldId++


		footer = form.footer().render()
		footer = renderTemplate(@format, "footer_#{footer.type}", footer.data)

		o = renderTemplate(@format, "form", {
			"fields" : o,
			"action" : action,
			"footer" : footer
		})
		return o

class BootstrapFormRenderer extends BasicFormRenderer
	constructor: () ->
		@format = "bootstrap"

@renderers['bootstrap'] = BootstrapFormRenderer