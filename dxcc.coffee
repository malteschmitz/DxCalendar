fs = require('fs')

class Dxcc

  get: (call) ->
    call = call.toUpperCase()
    while call.length > 0
      result = @records[call]
      return result if result?
      call = call.slice(0,-1)

  constructor: (filename) ->
    return new Dxcc(filename) unless @ instanceof Dxcc
    filename or= 'COUNTRY2.DAT'

    # create record object containing the data sorted by prefix
    @records = {}
    # create prefixes object containing all official prefixes as keys
    prefixes = {}

    # create array containing the current prefixes
    prefs = []

    # read content from file
    if fs.readFileSync?
      content = fs.readFileSync(filename, encoding: 'utf8')
    else if fs.read?
      content = fs.read(filename)
    else
      throw 'Unable to read content from file.'
    
    # parse content line by line
    lines = content.match(/[^\r\n]+/g)
    for line in lines
      # ignore comment lines
      unless /^\s*\/\//.test(line)
        line = line.trim()
        if /^\s*#.*#\s*$/.test(line)
          # parse country prefixes line
          prefs = line.match(/[^#\s]+/g).map (s) -> s.toUpperCase()
        else
          # parse country information line
          values = line.match(/[^\s]+/g)
          country =
            prefix: values[0].toUpperCase()
            prefixes: prefs
            name: values[1].replace('-', ' ')
            itu: values[2]
            waz: values[3]
            timeZone: values[4]
            latN: values[5]
            longE: values[6]
            adifNr: values[7]
          # insert prefix into object of all prefixes
          prefixes[country.prefix] = true
          # keep country information for every prefix
          for pref in prefs
            @records[pref] = country
          # reset list of current prefixes
          prefs = []
    # create prefixes array containing all official prefixes
    @prefixes = Object.keys(prefixes)

if module?.exports?
  module.exports = Dxcc
else if window?
  window.Dxcc = Dxcc
else
  this.Dxcc = Dxcc
