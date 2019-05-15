$ = (sel) -> document.querySelector sel

image = $ '#image'
input = $ '#text'
graph = $ '#graph'

file = null
canvas = null
text = ''
textCtx = null
redraw = null

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

            graph.innerHTML = ''
            link = ''
            graph.appendChild canvas

            canvas.addEventListener 'click', ->
                graph.href = canvas.toDataURL 'image/png', 1.0
                    .replace 'image/png', 'image/octet-stream'
                


        img.src = fileReader.result

    fileReader.readAsDataURL file


drawText = ->
    return if not canvas? or text.length is 0
    textSize = Math.max 15, (Math.min canvas.width, canvas.height) / 25
    
    if textCtx?
        redraw()
    else
        textCtx = canvas.getContext '2d'
        textCtx.fillStyle = 'rgba(0, 0, 255, 0.15)'
        textCtx.font = 'bold ' + textSize + 'px -apple-system,"Helvetica Neue",Helvetica,Arial,"PingFang SC","Hiragino Sans GB","WenQuanYi Micro Hei","Microsoft Yahei",sans-serif'
        textCtx.rotate 45 * Math.PI / 180
    
    width = (textCtx.measureText text).width
    step = Math.sqrt (Math.pow canvas.width, 2) + (Math.pow canvas.height, 2)
    margin = (textCtx.measureText '啊').width

    x = Math.ceil step / (width + margin)
    y = Math.ceil (step / (4 * textSize)) / 2

    for i in [0..x]
        for j in [-y..y]
            textCtx.fillText text, (width + margin) * i, 4 * textSize * j
    return


image.addEventListener 'change', ->
    file = @files[0]

    return alert '仅支持 png, jpg, gif 图片格式' if file.type not in ['image/png', 'image/jpeg', 'image.gif']
    readFile()

input.addEventListener 'input', ->
    text = @value
    drawText()

