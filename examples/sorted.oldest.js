var es = require('event-stream');
var HifoStream = require('../index');
var people = require('./people.json');

console.log('logging 3 items with highest `age`');
es.readArray(people)
.pipe(HifoStream.sorted(HifoStream.highest('age'), 3))
.on('data', function (data) {
  console.log(data);
});
