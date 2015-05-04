console.log('>>>>> this is in app.js')

var http = require('http');
var port = process.env.port || 1337;

console.log('>>>>> starting test server in azure in port ' + port)

http.createServer(function(req, res){
    res.writeHead(200, {'Content-Type':'text/plain'});
    res.end('Hello World\n');
}).listen(port);

console.log('>>>>> done')
