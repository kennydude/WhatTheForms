// https://github.com/paulmillr/async-each/
var async = {};
async.each = function(items, next, callback) {
if (!Array.isArray(items)) throw new TypeError('each() expects array as first argument');
if (typeof next !== 'function') throw new TypeError('each() expects function as second argument');
if (typeof callback !== 'function') callback = Function.prototype; // no-op
if (items.length === 0) return callback(undefined, items);
var transformed = new Array(items.length);
var count = 0;
var returned = false;
items.forEach(function(item, index) {
next(item, function(error, transformedItem) {
if (returned) return;
if (error) {
returned = true;
return callback(error);
}
transformed[index] = transformedItem;
count += 1;
if (count === items.length) return callback(undefined, transformed);
});
});
};
