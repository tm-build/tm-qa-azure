console.log('>>>>> this is in app.js')

var port = process.env.port || 1337;

console.log('>>>>> port is set to: ' + port)

require('../git_repos/TM_4_0_Windows/tm-design/app.js')

console.log('>>>>> done')
