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

# Goodbye SWIG
'''
swig = require("swig")
fallbackswigloader = require("fallbackswigloader")
if process?.env?.DEBUG? # Turn off template cache when in debug mode!
	swig.setDefaults({ cache: false })

compileTemplate = (renderer, template_name) ->
	loader = fallbackswigloader([
		"templates/#{renderer}",
		"templates/default"
	])
	f = "#{template_name}.html"
	return swig.precompile(loader.load(f), { filename: f})

renderTemplate = (renderer, template_name, data) ->
	swig.setDefaults {
		loader : fallbackswigloader([
			"templates/#{renderer}",
			"templates/default"
		])
	}
	return swig.renderFile("#{template_name}.html", data)
'''
# END SWIG

templateCache = {}
t5 = require "t5"

renderTemplate = (renderer, template_name, data) ->
	if templateCache[template_name]
		return templateCache[template_name].build()(ent, data)
	tpl = t5.compileFile("#{template_name}.html", {
		loader : new t5.T5FallbackFileTemplateLoader([
			"templates/#{renderer}",
			"templates/default"
		])
	})
	templateCache[template_name] = tpl
	return tpl.build()(ent, data)

class BasicFormRenderer extends FormRenderer
	script : (form, result) ->
		# Collect templates and other information
		templates = {}
		o = ''

		o += fs.readFileSync( path.join(__dirname, "..", "client", "gen", "WhatTheClass.js") ).toString()
		o += fs.readFileSync( path.join(__dirname, "..", "client", "gen", "core.js") ).toString()
		o += fs.readFileSync( path.join(__dirname, "..", "client", "miniswig.js") ).toString()
		o += fs.readFileSync( path.join(__dirname, "..", "node_modules", "async", "lib", "async.js") ).toString()

		for item in form.items
			vend = item.render(@format)
			if vend.type == "fieldset" # Special Case!
				console.log "Fieldset is not supported just yet"
			else
				scrp = item.script()
				if !(vend.type in templates)
					console.log vend.type
					#templates[vend.type] = compileTemplate(@format, vend.type).tpl.toString().replace('anonymous', '')

					scrp = item.script()
					o += fs.readFileSync( path.join(__dirname, "..", "client", "gen", scrp['require'] + ".js") ).toString()

				o += """
form["#{item.id()}"] = new #{scrp.class}()
						.properties(#{JSON.stringify(item.properties())})
						.clientGo(document.getElementById("wrap-#{item.id()}"));
"""
				ex = item.extraProps()
				for key, val of ex
					o += """
form["#{item.id()}"]["#{key}"] = #{val};
"""

		# Almost JSON, but it's actually just making a JS object!
		templates = "{" + ("\"#{k}\" : #{v}" for k, v of templates).join(",") + "}"
		o = """
var templates = #{templates};
var form = {};

#{o}
"""
		return o

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
