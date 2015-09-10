# hifo-stream

Stream interface for [hifo](https://github.com/derhuerst/hifo).

```
npm install hifo-stream
```

## Usage

### HifoStream.sorted()

Just like *hifo*, you can process an entire list and then get the final result,
sorted. The output will be a sorted list of individually emitted items.

```javascript
var es = require('event-stream');
var HifoStream = require('hifo-stream');
var people = require('./people.json');

console.log('logging 3 items with highest `age`');
es.readArray(people)
.pipe(HifoStream(HifoStream.highest('age'), 3).sorted())
.on('data', function (data) {
  console.log(data);
});
```

```
$ node examples/sorted.oldest.js
logging 3 items with highest `age`
{ name: 'John', age: 60 }
{ name: 'Eve', age: 45 }
{ name: 'Bob', age: 30 }
```

```
$ node examples/sorted.youngest.js
logging 3 items with lowest `age`
{ name: 'Jane', age: 19 }
{ name: 'Alice', age: 23 }
{ name: 'Bob', age: 30 }
```

### HifoStream.filter()

HifoStream.filter passes through items as they come in if they are in the top
`size` sorted items it has seen so far.

Warning #1: The problem with this method is the first `size` items will be
passed through, even if they are not the highest.

Warning #2: If `sortFunction` is *descending* (e.g. *highest*) and the input
stream emits items in *ascending order* (e.g. lowest-to-highest), then *every*
item from the input stream will pass through.

```javascript
var es = require('event-stream');
var HifoStream = require('hifo-stream');
var people = require('./people.json');

console.log('logging if item.age is in the lowest 2 seen so far');
es.readArray(people)
.pipe(HifoStream(HifoStream.lowest('age'), 2).filter())
.on('data', function (data) {
  console.log(data);
});
```

```
$ node examples/filter.youngest.js
logging if item.age is in the lowest 2 seen so far
{ name: 'Alice', age: 23 }
{ name: 'Eve', age: 45 }
{ name: 'Jane', age: 19 }
```

```
$ node examples/filter.oldest.js
logging if item.age is in the highest 2 seen so far
{ name: 'Alice', age: 23 }
{ name: 'Eve', age: 45 }
{ name: 'Bob', age: 30 }
{ name: 'John', age: 60 }
```

### HifoStream.update()

HifoStream.update is just like HifoStream.filter, execpt instead of emitting
each item, it sends the current sorted list.

```javascript
var es = require('event-stream');
var HifoStream = require('hifo-stream');
var people = require('./people.json');

console.log('logging sorted list if item.age is in the lowest 2 seen so far');
es.readArray(people)
.pipe(HifoStream(HifoStream.lowest('age'), 2).update())
.on('data', function (data) {
  console.log(data);
});
```

```
$ node examples/update.youngest.js
logging sorted list if item.age is in the lowest 2 seen so far
[ { name: 'Alice', age: 23 } ]
[ { name: 'Alice', age: 23 }, { name: 'Eve', age: 45 } ]
[ { name: 'Jane', age: 19 }, { name: 'Alice', age: 23 } ]
```

```
$ node examples/update.oldest.js
logging sorted list if item.age is in the highest 2 seen so far
[ { name: 'Alice', age: 23 } ]
[ { name: 'Eve', age: 45 }, { name: 'Alice', age: 23 } ]
[ { name: 'Eve', age: 45 }, { name: 'Bob', age: 30 } ]
[ { name: 'John', age: 60 }, { name: 'Eve', age: 45 } ]
```

## Tests

Tests are located in ./test/ and can be run via `npm test`
