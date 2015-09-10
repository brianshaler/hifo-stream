var es = require('event-stream');
var Hifo = require('hifo');

var HifoStream = Object.create(Hifo.Hifo);

HifoStream.sorted = function () {
  var self = this;
  var write = function (entry) {
    self.add(entry);
  };
  var end = function () {
    for (var i=0; i<self.data.length; i++) {
      this.emit('data', self.data[i]);
    }
    this.emit('end');
  };
  return es.through(write, end);
};

HifoStream.filter = function () {
  var self = this;
  var write = function (entry) {
    if (self.data.indexOf(entry) >= 0) { return; }
    if (self.insert(entry) >= 0) {
      this.emit('data', entry);
    }
  };
  return es.through(write);
};

HifoStream.update = function () {
  var self = this;
  var write = function (entry) {
    if (self.data.indexOf(entry) >= 0) { return; }
    if (self.insert(entry) >= 0) {
      this.emit('data', self.data);
    }
  };
  return es.through(write);
};

var factory = module.exports = function (sort, options) {
	var instance = Object.create(HifoStream);
	instance.init(sort, options);
	return instance;
};

factory.HifoStream = HifoStream;
factory.lowest = Hifo.lowest;
factory.highest = Hifo.highest;
