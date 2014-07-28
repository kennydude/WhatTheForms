# What the Forms?

This is a NodeJS module for dealing with forms.

Forms can be a tricky business, so we're here to help!

VERY EARLY ALPHA STAGE!!!!!

## Express

WhatTheForms works with Express, a quick guide of what you need to do:

	npm install body-parser --save

In app (Javascript):
	
```javascript
var bodyParser = require('body-parser');
app.use(bodyParser.urlencoded({ extended: false }))

app.use(function(req, res, next){
    res.error = function(err, msg){
        res.status(err).json({
            code:  err,
            message: msg
        });
    };
    next();
});
```

Note: The second app.use is a boilerplate used for errors, you should generally
use a HTML template so that users don't get confused. Essentially, it makes error
reporting really easy to do from your application.

## Notes

Some things are reserved for usage inside of WhatTheForms

* `GET /<your form URL>?request=whattheforms` - This returns the form metadata required for client-side validation.
  See [CDN](docs/CDN.md) to make this optimized for production applications.