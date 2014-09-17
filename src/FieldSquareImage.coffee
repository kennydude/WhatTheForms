# @exclude
fls = require "./Field"
@BasicField = fls.BasicField
# @endexclude

class @SquareImage extends @BasicField
    templateName : () ->
        return "field_square_image"
    script : () ->
        return { "require" : "SquareImage", "class" : "SquareImage" }
