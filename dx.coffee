adif = require('./adif')
dxcc = require('./dxcc')
webpage = require('webpage')



log = adif.Adif('DB7BN.adi')
# log.write('moep.adi')
console.log(log.records[10])



d = new dxcc.Dxcc
console.log(d.get('db7bn'))



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
