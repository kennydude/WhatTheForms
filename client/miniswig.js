/* mini swig */
window.swig = {
	run : function (tpl, locals) {
		var context = locals;
		return tpl(this, context, exports, /*utils*/{}, /*efn*/{});
	}
};

var exports = window.swig.filters = {};
var utils = {};
var isArray;

/**
 * Iterate over an array or object.
 * @param {array|object} obj Enumerable object.
 * @param {Function} fn Callback function executed for each item.
 * @return {array|object} The original input object.
 */
utils.each = function (obj, fn) {
	var i, l;

	if (isArray(obj)) {
		i = 0;
		l = obj.length;
		for (i; i < l; i += 1) {
			if (fn(obj[i], i, obj) === false) {
				break;
			}
		}
	} else {
		for (i in obj) {
			if (obj.hasOwnProperty(i)) {
				if (fn(obj[i], i, obj) === false) {
					break;
				}
			}
		}
	}

	return obj;
};

/**
 * Test if an object is an Array.
 * @param {object} obj
 * @return {boolean}
 */
utils.isArray = isArray = (Array.hasOwnProperty('isArray')) ? Array.isArray : function (obj) {
	return (obj) ? (typeof obj === 'object' && Object.prototype.toString.call(obj).indexOf() !== -1) : false;
};

/**
 * Helper method to recursively run a filter across an object/array and apply it to all of the object/array's values.
 * @param {*} input
 * @return {*}
 * @private
 */
function iterateFilter(input) {
	var self = this,
		out = {};

	if (utils.isArray(input)) {
		return utils.map(input, function (value) {
			return self.apply(null, arguments);
		});
	}

	if (typeof input === 'object') {
		utils.each(input, function (value, key) {
			out[key] = self.apply(null, arguments);
		});
		return out;
	}

	return;
}

/**
 * Force escape the output of the variable. Optionally use `e` as a shortcut filter name. This filter will be applied by default if autoescape is turned on.
 *
 * @example
 * {{ "<blah>"|escape }}
 * // => &lt;blah&gt;
 *
 * @example
 * {{ "<blah>"|e("js") }}
 * // => \u003Cblah\u003E
 *
 * @param {*} input
 * @param {string} [type='html'] If you pass the string js in as the type, output will be escaped so that it is safe for JavaScript execution.
 * @return {string} Escaped string.
 */
exports.escape = function (input, type) {
	var out = iterateFilter.apply(exports.escape, arguments),
		inp = input,
		i = 0,
		code;

	if (out !== undefined) {
		return out;
	}

	if (typeof input !== 'string') {
		return input;
	}

	out = '';

	switch (type) {
		case 'js':
			inp = inp.replace(/\\/g, '\\u005C');
			for (i; i < inp.length; i += 1) {
				code = inp.charCodeAt(i);
				if (code < 32) {
					code = code.toString(16).toUpperCase();
					code = (code.length < 2) ? '0' + code : code;
					out += '\\u00' + code;
				} else {
					out += inp[i];
				}
			}
			return out.replace(/&/g, '\\u0026')
				.replace(/</g, '\\u003C')
				.replace(/>/g, '\\u003E')
				.replace(/\'/g, '\\u0027')
				.replace(/"/g, '\\u0022')
				.replace(/\=/g, '\\u003D')
				.replace(/-/g, '\\u002D')
				.replace(/;/g, '\\u003B');

		default:
			return inp.replace(/&(?!amp;|lt;|gt;|quot;|#39;)/g, '&amp;')
				.replace(/</g, '&lt;')
				.replace(/>/g, '&gt;')
				.replace(/"/g, '&quot;')
				.replace(/'/g, '&#39;');
	}
};
exports.e = exports.escape;