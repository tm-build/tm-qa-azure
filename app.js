console.log('>>>>> this is in app.js')

var port = process.env.port || 1337;

console.log('>>>>> port is set to: ' + port)

require('../git_repos/TM_4_0_Design/app.js')

process.env.PORT=1332
require('../git_repos/TM_4_0_GraphDB/tm-graphdb/index.js')

console.log('>>>>> done')
