var gulp = require('gulp');
var replace = require('gulp-replace');
var coffee = require('gulp-coffee');
var preprocess = require('gulp-preprocess');
var concat = require('gulp-concat');
var fileinclude = require('gulp-file-include');

gulp.task("client", function(){
	return gulp .src("client/*.coffee")
				.pipe(coffee({bare: true}))
				.pipe(replace( /^([a-z]*) \= require\(\".+\"\).*$/gmi, '' ))
				.pipe(gulp.dest('client/gen'));
});

gulp.task('default', ["client"]);

gulp.task('dist', ["default"], function(){
	return gulp	.src("dist/WhatTheForms.coffee")
				.pipe(fileinclude({
					"prefix" : "#"
				}))
				.pipe(preprocess({context: { dist : true } }))
				.pipe(coffee())
				.pipe(gulp.dest("gen"));
})
