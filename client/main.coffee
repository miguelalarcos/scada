sourceData = @sourceData
sourceDataHist = @sourceDataHist

Meteor.subscribe 'sourceData'
Meteor.subscribe 'sourceDataHist'


UI.registerHelper 'dataValue', (variable)->
    item = sourceData.findOne(name:variable)
    if item
        this.value = item.value
        this._id = item._id
        this.variable = variable
        this
    else
        null

Template.swYesNo.helpers
    getColor: (variable)->
        item = sourceData.findOne(name:variable)
        if item
            if item.value then 'green' else 'red'
        else
            'black'

Template.swYesNo.events
    'click circle': (e,t)->
        Meteor.call 'Control', $(e.target).attr('variable')
        

Template.swBasicPerecentage.helpers
    getWidth: (value) ->
        w = this.width
        w*value/100
    getColor: (value) ->
        if value >= 50
            'red'
        else
            'green'
    xPosText: ->
        this.width/2

Template.swVelocimeter.helpers
    getColor: ->
        if this.value <= 50
            '#82FA58'
        else
            'pink'
    x2 : (value)-> 
        alfa = value*2*Math.PI/100.0
        25+25.0*Math.cos(alfa)
    y2 : (value)-> 
        alfa = value*2*Math.PI/100.0
        25+25.0*Math.sin(alfa)
    getAlfa: ->
        alfa = this.value*360/100.0


Template.grafica.rendered = ->
    height = 500
    width = 500
    d3.select("#grafica").attr("width", width).attr("height", height).append("path").attr("class", "line")
    d3.select("#grafica").append("path").attr("class", "rule")

Template.grafica.ayuda = ->
    data = sourceDataHist.find({}, {sort:{time:1} }).fetch()

    suma = 0
    for d, i in data
        suma += d.value

    console.log suma/i
    
    height = 500
    width = 500
    x = d3.scale.linear().range([0, width])
    y = d3.scale.linear().range([height, 0])
    
    valueline = d3.svg.line()
    .x((d)->x(d.time))
    .y((d)->y(d.value))
    
    x.domain(d3.extent(data, (d)-> d.time))
    y.domain([0, d3.max(data, (d)-> d.value)])

    path = d3.select("#grafica").select('path.line')
    #.append("g")
    #.attr("transform", "translate(" + '0' + "," + '0' + ")")
    path.attr("d", valueline(data))
    path = d3.select("#grafica").select('path.rule')
    min_max = d3.extent(data, (d)-> d.time)
    min = min_max[0]
    max = min_max[1]
    data = [[min, 50], [max, 50]]
    valueline = d3.svg.line().x( (d)->x(d[0]) ).y( (d)->y(d[1]) )
    path.attr("d", valueline(data))

    null