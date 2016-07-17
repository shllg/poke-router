_       = require 'lodash'
exit    = require 'exit'
Q       = require 'q'
fs      = require 'fs'
xml2js  = require 'xml2js'
Parser  = new xml2js.Parser()
Builder = new xml2js.Builder()

module.exports = new (class Main

  getConfig: ->
    @config or=
      timeForRoute: 1 * 60 * 60
      startAtNode: 0
      endAtNode: -1

  getRoutes: ->
    require('../routes')

  getFile: ->
    # # Müggelsee
    # # return 'mapstogpx20160713_112258'

    # # Zugspitze
    # # return 'mapstogpx20160713_155551'

    # # Eibsee
    # # return 'mapstogpx20160713_160045'

    # # Berlin Fhain / Mitte
    # # return 'mapstogpx20160715_200404'

    # # Berlin Tiergarten
    # # return 'mapstogpx20160715_221215'

    # # Tropical Island
    # return 'mapstogpx20160717_091914'

    @getRoutes().file

  run: ->
    @read()
    .then( (json) => @modify(json) )
    .then( (json) => @write(json) )
    .done()

  read: ->
    d = Q.defer()

    fs.readFile "data/#{@getFile()}.xml", (err, data) ->
      # convert XML-String to JSON
      Parser.parseString data, (err, result) ->
        # result contains the JSON object
        d.resolve(result)

    d.promise

  modify: (json) ->
    d = Q.defer()

    config      = @getConfig()
    waypoints   = _.size(json.gpx.wpt)
    stepSeconds = parseInt(config.timeForRoute / waypoints)
    startPoint  = config.startAtNode
    startPoint  = 0 if startPoint < 0
    endPoint    = config.endAtNode
    endPoint    = waypoints - 1 if endPoint < 0
    startStamp  = Date.now()

    console.log "----------------------------"
    console.log "Waypoints: \t #{waypoints}"
    console.log "P to p: \t #{stepSeconds} sec"
    console.log "Start point: \t #{startPoint}"
    console.log "End point: \t #{endPoint}"
    console.log "----------------------------"

    json.gpx.wpt = _.reduce json.gpx.wpt, (memo, item, index) =>
      return memo if index < startPoint
      return memo if index > endPoint

      stamp = parseInt(startStamp + ( index * stepSeconds * 1000 ))
      item.time = @_convertDate(stamp)

      memo.push item
      memo
    , []

    d.resolve(json)
    d.promise

  write: (json) ->
    xml = Builder.buildObject(json)

    fs.writeFile "data/#{@getFile()}_appended.xml", xml, (err) ->
      console.error err

  exit: (code) ->
    exit(code)

  _convertDate: (timestamp) ->
    date = new Date(timestamp)
    year      = date.getFullYear()
    month     = date.getMonth() + 1
    month     = "0#{month}" if month < 10
    day       = date.getDate()
    day       = "0#{day}" if day < 10
    hour      = date.getHours()
    hour      = "0#{hour}" if hour < 10
    minutes   = date.getMinutes()
    minutes   = "0#{minutes}" if minutes < 10
    seconds   = date.getSeconds()
    seconds   = "0#{seconds}" if seconds < 10
    "#{year}-#{month}-#{day}T#{hour}:#{minutes}:#{seconds}Z"


)