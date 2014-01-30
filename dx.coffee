Adif = require('./adif')
Dxcc = require('./dxcc')
webpage = require('webpage')

dxcc = Dxcc()
log = Adif('DB7BN.adi')

isConfirmed = (record) ->
  record.qslrdate?.length > 0 or
    record.qsl_rcvd?.toUpperCase() == 'Y'

count = {}
add = (args...) ->
  t = count
  for i in [0 .. args.length - 3]
    t[args[i]] = {} unless t[args[i]]?
    t = t[args[i]]
  key = args[args.length - 2]
  value = args[args.length - 1]
  t[key] = value unless t[key]?

bands = ["160m", "80m", "40m", "30m", "20m", "17m", "15m",
               "12m", "10m", "6m", "2m", "70cm", "23cm", "13cm",
               "9cm", "6cm", "3cm"]
modes = []

for index, record of log.records
  info = dxcc.get(record.call)
  if info?
    band = record.band.toLowerCase()
    bands.push(band) unless bands.indexOf(band) > -1
    mode = record.mode.toLowerCase()
    modes.push(mode) unless modes.indexOf(mode) > -1
    add(info.prefix, band, mode, isConfirmed(record),
      qso: record, info: info)

console.log(JSON.stringify(modes))
console.log(JSON.stringify(bands))

console.log(JSON.stringify(count.DL))


# early exit for debugging
phantom.exit()


page = webpage.create()
page.open 'http://dxfor.me/upcoming', (status) ->
  if status != 'success'
    console.log('Unable to access DX For Me')
  else
    upcomings = page.evaluate ->
      $('.upcoming_now').closest('tr').map ->
        message: $(@).next('tr').find('td.message').text()
        date_from: $(@).find('td:eq(0)').text()
        date_to: $(@).find('td:eq(7)').text()
        call: $(@).find('td:eq(2) a:first').text()
        url: $(@).find('td:eq(2) a:first').attr('href')
    for u in upcomings
      console.log(u.call + ';' + u.date_from + ';' +
        u.date_to + ';' + u.message + ';' + u.url)
  phantom.exit()
