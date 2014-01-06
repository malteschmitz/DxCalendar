Adif = require('./adif')
Dxcc = require('./dxcc')
webpage = require('webpage')



# log = Adif('DB7BN.adi')
# r = log.records[10]
# for k,v of r
#   console.log(k + '\t' + v)
#log.write('moep.adi')



# d = Dxcc()
# entry = d.get('db7bn')
# for k,v of entry
#   console.log(k + '\t' + v)



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
