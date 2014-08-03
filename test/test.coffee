# Basic "does it work" tests
process.env['DEBUG'] = true

WhatTheForms = require("../src/WhatTheForms.coffee")

form = new WhatTheForms.Form().action("/form")

form.add( new WhatTheForms.BasicField().type("text").name("test1").label("Testing").placeholder("OKFISH").validate(/^[a-z]$/g) )

fieldset = new WhatTheForms.Fieldset().label("Bank details")
fieldset.add( new WhatTheForms.TextField().name("test2").label("Testing").placeholder("OKFISH") )

form.add(fieldset)

'''
form.footer(new WhatTheForms.StripeFooter({
	"title" : "EGG"
}))
'''

console.log form.render("bootstrap")

express = require("express")
bodyParser = require('body-parser')


app = express()
app.use(bodyParser.urlencoded({ extended: false }))

app.use (req, res, next) ->
	res.error = (err, msg) ->
		res.status(err).json({
			code:  err,
			message: msg
		})
	next()

app.all "/form", form.controller(
	(req, res) ->
		frm = form.render('bootstrap')
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