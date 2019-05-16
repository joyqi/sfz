$ = (sel) -> document.querySelector sel

el =
    image: $ '#image'
    text: $ '#text'
    graph: $ '#graph'
    color: $ '#color'
    alpha: $ '#alpha'
    space: $ '#space'

file = null
canvas = null
text = el.text.value
color = el.color.value
alpha = el.alpha.value
space = el.space.value
textCtx = null
redraw = null

dataURItoBlob = (dataURI) ->
    binStr = atob (dataURI.split ',')[1]
    len = binStr.length
    arr = new Uint8Array len

    for i in [0..len - 1]
        arr[i] = binStr.charCodeAt i
    new Blob [arr], type: 'image/png'


readFile = ->
    return if not file?

    fileReader = new FileReader

    fileReader.onload = ->
        img = new Image
        img.onload = ->
            canvas = document.createElement 'canvas'
            canvas.width = img.width
            canvas.height = img.height
            textCtx = null
            
            ctx = canvas.getContext '2d'
            ctx.drawImage img, 0, 0

            redraw = ->
                ctx.rotate 315 * Math.PI / 180
                ctx.clearRect 0, 0, canvas.width, canvas.height
                ctx.drawImage img, 0, 0
                ctx.rotate 45 * Math.PI / 180
            
            drawText()

            el.graph.innerHTML = ''
            el.graph.appendChild canvas

            canvas.addEventListener 'click', ->
                link = document.createElement 'a'
                link.download = 'image.png'
                imageData = canvas.toDataURL 'image/png'
                blob = dataURItoBlob imageData
                link.href = URL.createObjectURL blob

                setTimeout ->
                    link.click()
                , 100
                


        img.src = fileReader.result

    fileReader.readAsDataURL file
    

makeStyle = ->
    match = color.match /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i

    'rgba(' + (parseInt match[1], 16) + ',' + (parseInt match[2], 16) + ',' \
         + (parseInt match[3], 16) + ',' + alpha + ')'


drawText = ->
    return if not canvas? or text.length is 0
    textSize = Math.max 15, (Math.min canvas.width, canvas.height) / 25
    
    if textCtx?
        redraw()
    else
        textCtx = canvas.getContext '2d'
        textCtx.font = 'bold ' + textSize + 'px -apple-system,"Helvetica Neue",Helvetica,Arial,"PingFang SC","Hiragino Sans GB","WenQuanYi Micro Hei","Microsoft Yahei",sans-serif'
        textCtx.rotate 45 * Math.PI / 180
    
    textCtx.fillStyle = makeStyle()
    width = (textCtx.measureText text).width
    step = Math.sqrt (Math.pow canvas.width, 2) + (Math.pow canvas.height, 2)
    margin = (textCtx.measureText '啊').width

    x = Math.ceil step / (width + margin)
    y = Math.ceil (step / (space * textSize)) / 2

    for i in [0..x]
        for j in [-y..y]
            textCtx.fillText text, (width + margin) * i, space * textSize * j
    return


el.image.addEventListener 'change', ->
    file = @files[0]

    return alert '仅支持 png, jpg, gif 图片格式' if file.type not in ['image/png', 'image/jpeg', 'image/gif']
    readFile()

el.text.addEventListener 'input', ->
    text = @value
    drawText()

el.alpha.addEventListener 'input', ->
    alpha = @value
    drawText()

el.color.addEventListener 'input', ->
    color = @value
    drawText()

el.space.addEventListener 'input', ->
    space = @value
    drawText()

