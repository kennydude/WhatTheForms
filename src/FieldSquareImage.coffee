# @exclude
fls = require "./Field"
@BasicField = fls.BasicField
# @endexclude

class @SquareImage extends @BasicField
    @property "size", 75

    client: () ->
        return """{
    "id" : #{JSON.stringify(@id())},
    "size" : #{JSON.stringify(@size())}
}"""

    templateName : () ->
        return "field_square_image"
    script : () ->
        return { "require" : "SquareImage", "class" : "SquareImage" }
