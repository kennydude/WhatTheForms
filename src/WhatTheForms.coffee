merge = (obj) =>
	for k, v of obj
		this[k] = v

merge(require("./WhatTheClass"))
merge(require("./Form"))
merge(require("./Field"))
merge(require("./Fieldset"))
merge(require("./Footer"))
merge(require("./MoreFields"))
