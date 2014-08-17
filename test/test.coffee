# Basic "does it work" tests
process.env['DEBUG'] = true

WhatTheForms = require("../lib/WhatTheForms.coffee")

form = new WhatTheForms.Form().action("/form")

srv = (val, req, cb) ->
	console.log "value: ", val
	if val == "egg"
		return cb "Eggs are illegal"
	cb null # We do not like eggs

form.add(
	new WhatTheForms.BasicField().type("text").name("test1")
		.label("Testing").placeholder("OKFISH").validate(/^[a-z]$/g)
		.validateServer(srv)
)
form.add new WhatTheForms.CSRFField()

form.add new WhatTheForms.SelectField().label("Country").option("uk", "United Kingdom").option("us", "United States")
form.add new WhatTheForms.StaticField().label("Subscriber No").value("129437249")

fieldset = new WhatTheForms.Fieldset().label("Bank details")
fieldset.add new WhatTheForms.TextField().name("test2").label("Testing").placeholder("OKFISH").validate(/^[a-z]$/g)

form.add(fieldset)

'''
form.footer(new WhatTheForms.StripeFooter({
	"title" : "EGG"
}))
'''

#console.log form.render("bootstrap")

express = require("express")
bodyParser = require('body-parser')
cookieParser = require('cookie-parser')


app = express()
app.use(bodyParser.urlencoded({ extended: false }))
app.use(cookieParser("https://www.youtube.com/watch?v=sTSA_sWGM44"))

app.use (req, res, next) ->
	res.error = (err, msg) ->
		res.status(err).json({
			code:  err,
			message: msg
		})
	next()

app.all "/form", form.controller(
	(req, res) ->
		frm = form.render('bootstrap', req.body, req, res)
		res.end """
<html>
<head>
	<title>Form</title>
	<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
</head>
<body>
<div class="container">
	#{frm}
</div>
<script type="text/javascript" src="/form?request=whattheforms&cmd=js"></script>
</body>
</html>
"""
	(req, res) ->
		res.end "validated!"
)

app.listen 8080
console.log "ok on http://localhost:8080"
