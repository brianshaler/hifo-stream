var es = require('event-stream');
var HifoStream = require('../index');
var people = require('./people.json');

console.log('logging sorted list if item.age is in the highest 2 seen so far');
es.readArray(people)
.pipe(HifoStream.update(HifoStream.highest('age'), 2))
.on('data', function (data) {
  console.log(data);
});
