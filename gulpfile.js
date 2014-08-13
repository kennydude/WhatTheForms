var gulp = require('gulp');
var replace = require('gulp-replace');
var coffee = require('gulp-coffee');

gulp.task("client", function(){
	return gulp .src("client/*.coffee")
				.pipe(coffee({bare: true}))
				.pipe(replace( /^([a-z]*) \= require\(\".+\"\).*$/gmi, '' ))
				.pipe(gulp.dest('client/gen'));
});

gulp.task('default', ["client"]);
