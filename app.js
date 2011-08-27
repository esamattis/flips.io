
if ( process.env.NODE_ENV === 'production') {
  require('nko')("48YWkNlKZe/RWmln", function(err, res) {
      if (err) {
        throw err;
      }
      res.on('data', function(d) {
        console.log("Reported to node.ko", d.toString());
      });
  });
}

require("coffee-script");
var app = require("./server");

app.listen(process.env.NODE_ENV === 'production' ? 80 : 8000, function() {
  console.log('Ready');

  // if run as root, downgrade to the owner of this file
  if (process.getuid() === 0)
    require('fs').stat(__filename, function(err, stats) {
      if (err) return console.log(err)
      process.setuid(stats.uid);
    });
});

