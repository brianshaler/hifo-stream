var es = require('event-stream');

var Hifo = function (sort, size) {
  var data = [];
  var add = function (entry) {
    var i;

    // `this.data` is empty
    if (data.length === 0) {
      data.push(entry);
      //this.emit('data', entry);
      return 0;
    }

    // abort if `entry` is lower than the last
    if (data.length >= size
    && sort(data[data.length - 1], entry) < 0)
      return;

    // check if `entry` exists
    i = data.indexOf(entry);
    if (i >= 0) return;   // do nothing

    // move forward
    i = data.length - 1;
    while (i >= 0 && sort(data[i], entry) >= 0) i--;
    data.splice(i + 1, 0, entry);   // add
    //this.emit('data', entry);

    // `this.data` is full
    if (data.length > size) data.pop();   // remove last
    return i + 1;
  };
  return {
    add: add,
    data: data
  };
}

module.exports = {
  sorted: function (sort, size) {
		if (!sort) throw new Error('Missing `sort` parameter.');
		size = size || 10;
    var hifo = Hifo(sort, size);
    var write = function (data) {
      hifo.add(data);
    };
    var end = function () {
      for (var i=0; i<hifo.data.length; i++) {
        this.emit('data', hifo.data[i]);
      }
      this.emit('end');
    };
    return es.through(write, end);
  },
  filter: function (sort, size) {
		if (!sort) throw new Error('Missing `sort` parameter.');
		size = size || 10;
    var hifo = Hifo(sort, size);
    var write = function (entry) {
      if (hifo.add(entry) >= 0) {
        this.emit('data', entry);
      }
    };
    return es.through(write);
  },
  update: function (sort, size) {
		if (!sort) throw new Error('Missing `sort` parameter.');
		size = size || 10;
    var hifo = Hifo(sort, size);
    var write = function (entry) {
      if (hifo.add(entry) >= 0) {
        this.emit('data', hifo.data);
      }
    };
    return es.through(write);
  },
  lowest: function (primary, secondary) {
  	if (arguments.length === 2)
  		return function (a, b) {
  			var d = a[primary] - b[primary];
  			if (d === 0) return a[secondary] - b[secondary];
  			else return d;
  		};
  	else if (typeof primary === 'string')
  		return function (a, b) { return a[primary] - b[primary] };
  	else return function (a, b) { return a - b };;
  },
  highest: function (primary, secondary) {
  	if (arguments.length === 2)
  		return function (a, b) {
  			var d = b[primary] - a[primary];
  			if (d === 0) return b[secondary] - a[secondary];
  			else return d;
  		};
  	else if (typeof primary === 'string')
  		return function (a, b) { return b[primary] - a[primary] };
  	else return function (a, b) { return b - a };
  }
};
