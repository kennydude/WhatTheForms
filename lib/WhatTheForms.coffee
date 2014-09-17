merge = (obj) =>
	for k, v of obj
		this[k] = v

merge(require("../src/WhatTheClass"))
merge(require("../src/Form"))
merge(require("../src/Field"))
merge(require("../src/Fieldset"))
merge(require("../src/Footer"))
merge(require("../src/MoreFields"))
merge(require("../src/FieldSquareImage"))
