class @Box extends @WhatTheClass
	go : (wrap, data) ->
		console.log "go(wrap, data) is not implemented!"
@encQS = (qs) ->
	o = []
	for k, v of qs
		o.push encodeURIComponent(k) + "=" + encodeURIComponent(v)
	return o.join("&")
