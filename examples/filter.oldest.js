var es = require('event-stream');
var HifoStream = require('../index');
var people = require('./people.json');

console.log('logging if item.age is in the highest 2 seen so far');
es.readArray(people)
.pipe(HifoStream.filter(HifoStream.highest('age'), 2))
.on('data', function (data) {
  console.log(data);
});
