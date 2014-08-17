@FormRenderers = {}

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

compileTemplate = (renderer, template_name, attrs) ->
	if templateCache[template_name]
		return templateCache[template_name]

	folders = []
	for mainDir in attrs.folders.concat([ path.join( __dirname, "..", "templates" ) ])
		folders.push path.join mainDir, renderer
		folders.push path.join mainDir, "default"

	tpl = t5.compileFile("#{template_name}.html", {
		loader : new t5.T5FallbackFileTemplateLoader(folders),
		name : "tpl_#{template_name}"
	})
	templateCache[template_name] = tpl
	return tpl

renderTemplate = (renderer, template_name, data, attrs) ->
	return compileTemplate(renderer, template_name, attrs).build()(ent, data)

class BasicFormRenderer extends FormRenderer
	scriptField : (vend, item) ->
		scrp = vend.script
		if scrp == null
			return

		if !(@templates[vend.type])
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
			vend = item.render()
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

	render: (form, result, req, res, attrs) ->
		action = ent.encode form.action()
		o = []
		fldId = 0

		if !attrs
			attrs = {}
		attrs.folders = attrs.folders || []

		for item in form.items
			item.id(form._name + "fld" + fldId)

			vend = item.render req, res, form
			if vend.type == "fieldset" # Fieldsets are handled differently at the moment
				if !vend['data']
					vend.data = {}

				vend.data.fields = []
				for field in vend.fields
					field.data.error = result?.errors?[item.id()]?[field.id]
					rv = result?[item.id()]?[field.id]
					if rv
						field.data.value = rv
					vend.data.fields.push {
						"id" : field.id.toString(),
						"value" : renderTemplate(@format, field.type, field.data, attrs)
					}
					fldId++
			else
				# Add result
				vend.data.error = result?.errors?[ item.id() ]
				rv = result?[ item.id() ]
				if rv
					vend.data.value = rv

			o.push {
				"id" : item.id()
				"value" : renderTemplate(@format, vend.type, vend.data, attrs)
			}
			fldId++


		footer = form.footer().render()
		footer = renderTemplate(@format, "footer_#{footer.type}", footer.data, attrs)

		o = renderTemplate(@format, "form", {
			"fields" : o,
			"action" : action,
			"footer" : footer,
			"name" : form.name()
		}, attrs)
		return o

class BootstrapFormRenderer extends BasicFormRenderer
	constructor: () ->
		@format = "bootstrap"

@FormRenderers['bootstrap'] = BootstrapFormRenderer

class DefaultFormRenderer extends BasicFormRenderer
	constructor: () ->
		@format = "default"

@FormRenderers['default'] = DefaultFormRenderer
