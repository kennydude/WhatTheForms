class @SquareImage extends @Field
    setP : () ->
        @template.rimg.style.left = @left + "px"
        @template.rimg.style.top = @top + "px"

    zoom : () ->
        @scaled_width = ( @width * @template.zoom.value )
        @scaled_height = ( @height * @template.zoom.value )

        @template.rimg.style.width = @scaled_width + "px";
        @template.rimg.style.height = @scaled_height + "px"

    go: (wrap, data) ->
        @left = 0
        @top = 0

        @template = new tpl_field_square_image(wrap, { "client" : true })

        @template.dialog.style.maxWidth = "500px"
        dialogPolyfill @template.dialog

        @template.container.style.width = data.size + "px"
        @template.container.style.height = data.size + "px"
        @template.container.style.position = "relative"
        @template.container.style.overflow = "hidden"

        @template.rimg.style.position = "absolute"
        @template.rimg.style.left = "0px"
        @template.rimg.style.top = "0px"
        @template.rimg.style.imageRendering = "optimizeQuality"

        @template.rimg.addEventListener "mousedown", (e) ->
            e.preventDefault()

        @template.container.addEventListener "mousedown", (e) =>
            @moving = true
            @orig = { x : e.clientX, y : e.clientY }

        # Window is used here so dragging doesn't muck up once you
        # leave the elememt
        window.addEventListener "mouseup", (e) =>
            @moving = false

        window.addEventListener "mousemove", (e) =>
            if @moving
                @left -= @orig.x - e.clientX
                @top -= @orig.y - e.clientY

                @setP()

                @orig = { x : e.clientX, y : e.clientY }

        # Load image
        @template.file.addEventListener "change", (e) =>
            file = @template.file.files[0]
            imageType = /image.*/

            if (file.type.match(imageType))
                @template.rimg.removeAttribute "width"
                @template.rimg.removeAttribute "height"
                @template.zoom.value = 1
                @template.fileSelected = true

            	reader = new FileReader()

            	reader.onload = (e) =>
                    @template.rimg.src = reader.result

            	reader.readAsDataURL(file)
        @template.rimg.addEventListener "load", () =>
            @left = 0
            @top = 0
            @width = @template.rimg.width
            @height = @template.rimg.height

            @setP()

        # Now add the slider stuff
        @template.zoom.addEventListener "change", (e) => @zoom(e)
        @template.zoom.addEventListener "input", (e) => @zoom(e)

        # Open me!
        @template.changeImage.addEventListener "click", () =>
            @template.dialog.showModal()

        # Close Me!
        @template.save.addEventListener "click", () =>
            # Save
            canvas = document.createElement "canvas"
            canvas.width = data.size
            canvas.height = data.size

            context = canvas.getContext "2d"
            context.imageSmoothingEnabled = no
            context.mozImageSmoothingEnabled = no

            context.drawImage(
                @template.rimg,
                Math.round(@left),
                Math.round(@top),
                Math.round(@scaled_height),
                Math.round(@scaled_width)
            )

            @template.value = canvas.toDataURL()

            @template.dialog.close()

        return @
