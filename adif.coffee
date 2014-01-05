fs = require('fs')

class @Adif
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

  #t = '123Moep\n<adiv_ver:4>1.00<eom>Hallo'
  #data = fields(t, 3, '<eoh>', true)
  #console.log(data)
  #console.log(t.slice(data.lastIndex))

  # write adif fields
  # file - the output file descriptor
  # table - the table with the fields to write into the file
  # comment - set to true if you want to write comment field as first lines
  text = (file, table, comment) ->
    if comment
      fs.writeSync(file, table.comment + '\n')
      delete table.comment
    for key, value of table
      fs.writeSync(file, '<' + key + ':' + value.length + '>' + value + '\n')

  # Read the header and all records of given ADIF file.
  # filename - the filename of the ADIF file to read
  constructor: (filename) ->
    return new Adif(filename) unless @ instanceof Adif
    @records = []
    @header = {}
    if filename
      content = fs.readFileSync(filename, encoding: 'utf8')
      result = fields(content, 0, '<eoh>', true)
      if result.lastIndex > 0
        @header = result.record
      loop
        result = fields(content, result.lastIndex, '<eor>')
        return @ if result.lastIndex == 0
        @records.push(result.record)

  @read: Adif

  # Write header and all records to the given file name
  write: (filename) ->
    # open file descriptor
    file = fs.openSync(filename, 'w')

    # write header
    text(file, @header, true)
    fs.writeSync(file, '<eoh>\n\n')

    # write records
    for record in @records
      text(file, record)
      fs.writeSync(file, '<eor>\n\n')

    # close file
    fs.closeSync(file)


