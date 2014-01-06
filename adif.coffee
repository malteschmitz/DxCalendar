fs = require('fs')

class Adif
  # escape user input for usage in an regular expression
  escapeRegExp = (string) ->
    string.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1")

  # read adif fields
  # t - the input string
  # offset - the first index of the substring to read
  # end_tag - the tag ending the current entry, e.g. '<eor>'
  # comment - set to true if you want to get first lines as comment field
  fields = (t, offset, end_tag, comment) ->
    data = record: {}
    re = new RegExp('<(\\w+):(\\d+)>|' +
      escapeRegExp(end_tag), 'gi')
    re.lastIndex = offset
    result = re.exec(t)
    if comment
      comment = t.slice(offset, result?.index)
      if not /$\s*^/.test(comment)
        data.record.comment = comment.trim()
    while result? and result[0] != end_tag
      length = +result[2]
      data.record[result[1]] = t.substr(re.lastIndex, length)
      re.lastIndex += length
      result = re.exec(t)
    data.lastIndex = re.lastIndex
    data

  # create adif fields
  # table - the table with the fields to write into the file
  # comment - set to true if you want to write comment field as first lines
  # returns - a string containing all the fields from the table in ADIF format
  text = (table, comment) ->
    content = ''
    if comment
      content += table.comment + '\n'
      delete table.comment
    for key, value of table
      content += '<' + key + ':' + value.length + '>' + value + '\n'
    content

  # Read the header and all records of given ADIF file.
  # filename - the filename of the ADIF file to read
  constructor: (filename) ->
    return new Adif(filename) unless @ instanceof Adif
    @records = []
    @header = {}
    if filename
      # read content from file
      if fs.readFileSync?
        content = fs.readFileSync(filename, encoding: 'ascii')
      else if fs.read?
        content = fs.read(filename)
      else
        throw "Unable to read content from file."

      # parse header
      result = fields(content, 0, '<eoh>', true)
      if result.lastIndex > 0
        @header = result.record

      # parse records
      loop
        result = fields(content, result.lastIndex, '<eor>')
        return @ if result.lastIndex == 0
        @records.push(result.record)

  @read: Adif

  # Write header and all records to the given file name
  write: (filename) ->
    # generate header
    content = text(@header, true)
    content += '<eoh>\n\n'

    # generate records
    for record in @records
      content += text(record)
      content += '<eor>\n\n'

    # write content to file
    if fs.writeFileSync?
      fs.writeFileSync(filename, content, encoding: 'ascii')
    else if fs.write?
      fs.write(filename, content, 'w')
    else
      throw 'Unable to write content to file.'

if module?.exports?
  module.exports = Adif
else if window?
  window.Adif = Adif
else
  this.Adif = Adif
