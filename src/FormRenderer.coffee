@renderers = {}

class FormRenderer
	constructor: () ->
		throw new Error("Abstract class cannot be initialized")
	render: (form) ->
		throw new Error("render(form) is not implemented")

# Included Classes

ent = require("ent")
fs = require("fs")
mustache = require("mustache")
templateCache = {}

findTemplate = (renderer, template_name) ->
	filepaths = [
		"templates/#{renderer}/#{template_name}.mustache",
		"templates/default/#{template_name}.mustache"
	]
	for path in filepaths
		try
			return fs.readFileSync(path).toString()
		catch
	return null

# DO NOT USE!!
bakeTemplate = (renderer, template_name) ->
	file = findTemplate(renderer, template_name)
	if file.indexOf("@extends") == 0
		# This template inherits from another
		line = file.split("\n")[0]
		ext = line.substr( "@extends ".length )
		file = file.substr( line.length )
		file = bakeTemplate(renderer, ext).replace("{{CONTENTS}}", file)
	return file

# Use me! :D
renderMustache = (renderer, template_name, data) ->
	if template_name not in templateCache
		templateCache[template_name] = bakeTemplate(renderer, template_name)
	return mustache.render( templateCache[template_name], data )

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
						"id" : field.id,
						"value" : renderMustache(@format, field.type, field.data)
					}
					fldId++

			o.push {
				"id" : item.id
				"value" : renderMustache(@format, vend.type, vend.data)
			}
			fldId++


		footer = form.footer().render()
		footer = renderMustache(@format, "footer_#{footer.type}", footer.data)

		o = renderMustache(@format, "form", {
			"fields" : o,
			"action" : action,
			"footer" : footer
		})
		return o

class BootstrapFormRenderer extends BasicFormRenderer
	constructor: () ->
		@format = "bootstrap"

@renderers['bootstrap'] = BootstrapFormRenderer