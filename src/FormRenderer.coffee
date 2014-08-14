@renderers = {}

class FormRenderer
	constructor: () ->
		throw new Error("Abstract class cannot be initialized")
	render: (form) ->
		throw new Error("render(form) is not implemented")

# Included Classes

ent = require("ent")
fs = require("fs")
path = require("path")

templateCache = {}
t5 = require "t5"

compileTemplate = (renderer, template_name) ->
	if templateCache[template_name]
		return templateCache[template_name]
	tpl = t5.compileFile("#{template_name}.html", {
		loader : new t5.T5FallbackFileTemplateLoader([
			"templates/#{renderer}",
			"templates/default"
		]),
		name : "tpl_#{template_name}"
	})
	templateCache[template_name] = tpl
	return tpl

renderTemplate = (renderer, template_name, data) ->
	return compileTemplate(renderer, template_name).build()(ent, data)

class BasicFormRenderer extends FormRenderer
	scriptField : (vend, item) ->
		scrp = vend.script

		if !(@templates[vend.type])
			console.log vend.type
			@templates[vend.type] = true
			@o += compileTemplate(@format, vend.type).manageClass
			@o += fs.readFileSync( path.join(__dirname, "..", "client", "gen", scrp['require'] + ".js") ).toString()

		@o += """
form["#{vend.id}"] = new #{scrp.class}().go(document.getElementById("wrap-#{vend.id}"), #{vend.client});
"""

	script : (form, result) ->
		# Collect templates and other information
		@templates = {}
		@o = ''

		@o += fs.readFileSync( path.join(__dirname, "..", "client", "gen", "WhatTheClass.js") ).toString()
		@o += fs.readFileSync( path.join(__dirname, "..", "client", "gen", "core.js") ).toString()
		@o += fs.readFileSync( path.join(__dirname, "..", "client", "async-each.js") ).toString()
		@o += fs.readFileSync( path.join(__dirname, "..", "client", "microajax.js") ).toString()

		for item in form.items
			vend = item.render(@format)
			if vend.type == "fieldset" # Special Case!
				for f in vend.fields
					@scriptField(f)
			else
				@scriptField(vend)

		@o = """
var form = { "action" : "#{form.action()}" };

#{@o}
"""
		return @o

	render: (form, result) ->
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
					field.data.error = result?.errors?[item.id()]?[field.id]
					field.data.value = result?[item.id()]?[field.id]
					vend.data.fields.push {
						"id" : field.id.toString(),
						"value" : renderTemplate(@format, field.type, field.data)
					}
					fldId++
			else
				# Add result
				vend.data.error = result?.errors?[ item.id() ]
				vend.data.value = result?[ item.id() ]

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
			"footer" : footer,
			"name" : form.name()
		})
		return o

class BootstrapFormRenderer extends BasicFormRenderer
	constructor: () ->
		@format = "bootstrap"

@renderers['bootstrap'] = BootstrapFormRenderer
