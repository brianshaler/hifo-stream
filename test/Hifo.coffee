mocha =  require 'mocha'
assert = require 'assert'
es =     require 'event-stream'

HifoStream = require '../index'

piDigit = (i) -> Math.round Math.PI * Math.pow(10, i) % 10

piIntStream = () ->
  stream = es.through((data) -> @emit 'data', data)
  index = 0

  stream: stream
  writeNext: (count) ->
    count = 1 unless count > 1
    for i in [1..count] by 1
      stream.write piDigit index++

piObjectStream = (valueKey = 'value') ->
  stream = es.through((data) -> @emit 'data', data)
  index = 0

  stream: stream
  writeNext: (count) ->
    count = 1 unless count > 1
    for i in [1..count] by 1
      obj =
        i: i
      obj[valueKey] = piDigit index++
      stream.write obj

describe 'HifoStream', () ->

  it 'should require a `sort` function', () ->
    assert.throws () ->
      HifoStream()
    assert.doesNotThrow () ->
      HifoStream HifoStream.lowest()

  describe 'sorted', () ->

    it 'should fill `data` until `size` is reached', () ->
      hifo = HifoStream HifoStream.lowest(), 2
      stream = hifo.sorted()
      result = []
      input = piIntStream()

      input.stream
      .pipe stream
      .on 'data', (data) ->
        result.push data

      input.writeNext 3
      assert.equal result.length, 0
      input.stream.end()
      assert.equal result.length, 2

    it 'should sort integer `data` by `lowest`', () ->
      hifo = HifoStream HifoStream.lowest(), 4
      stream = hifo.sorted()
      result = []
      input = piIntStream()

      input.stream
      .pipe stream
      .on 'data', (data) ->
        result.push data

      input.writeNext 4
      assert.equal result.length, 0
      input.stream.end()
      assert.deepEqual result, [1, 2, 3, 4]

    it 'should sort integer `data` by `highest`', () ->
      hifo = HifoStream HifoStream.highest(), 5
      stream = hifo.sorted()
      result = []
      input = piIntStream()

      input.stream
      .pipe stream
      .on 'data', (data) ->
        result.push data

      input.writeNext 7
      assert.equal result.length, 0
      input.stream.end()
      assert.deepEqual result, [9, 6, 4, 3, 2]

    it 'should sort object `data` by `lowest(\'value\')`', () ->
      hifo = HifoStream HifoStream.lowest('value'), 4
      stream = hifo.sorted()
      result = []
      input = piObjectStream 'value'

      input.stream
      .pipe stream
      .on 'data', (data) ->
        result.push data

      input.writeNext 7
      assert.equal result.length, 0
      input.stream.end()
      assert.deepEqual result, [
        { i: 2, value: 1 }
        { i: 4, value: 2 }
        { i: 7, value: 3 }
        { i: 1, value: 3 }
      ]

    it 'should sort object `data` by `lowest(\'a\', \'b\')`', () ->
      hifo = HifoStream HifoStream.lowest('value', 'i'), 4
      stream = hifo.sorted()
      result = []
      input = piObjectStream 'value'

      input.stream
      .pipe stream
      .on 'data', (data) ->
        result.push data

      input.writeNext 7
      assert.equal result.length, 0
      input.stream.end()
      assert.deepEqual result, [
        { i: 2, value: 1 }
        { i: 4, value: 2 }
        { i: 1, value: 3 }
        { i: 7, value: 3 }
      ]

    it 'should sort object `data` by `highest(\'value\')`', () ->
      hifo = HifoStream HifoStream.highest('value'), 5
      stream = hifo.sorted()
      result = []
      input = piObjectStream 'value'

      input.stream
      .pipe stream
      .on 'data', (data) ->
        result.push data

      input.writeNext 7
      assert.equal result.length, 0
      input.stream.end()
      assert.deepEqual result, [
        { i: 6, value: 9 }
        { i: 5, value: 6 }
        { i: 3, value: 4 }
        { i: 7, value: 3 }
        { i: 1, value: 3 }
      ]

    it 'should sort object `data` by `highest(\'a\', \'b\')`', () ->
      hifo = HifoStream HifoStream.highest('value', 'i'), 5
      stream = hifo.sorted()
      result = []
      input = piObjectStream 'value'

      input.stream
      .pipe stream
      .on 'data', (data) ->
        result.push data

      input.writeNext 7
      assert.equal result.length, 0
      input.stream.end()
      assert.deepEqual result, [
        { i: 6, value: 9 }
        { i: 5, value: 6 }
        { i: 3, value: 4 }
        { i: 7, value: 3 }
        { i: 1, value: 3 }
      ]

    it 'should not emit an event for the same number twice', () ->
      hifo = HifoStream HifoStream.highest(), 7
      stream = hifo.sorted()
      count = 0
      input = piIntStream()

      input.stream
      .pipe stream
      .on 'data', (data) ->
        count++

      input.writeNext 7
      assert.equal count, 0
      input.stream.end()
      assert.equal count, 6

    it 'should not emit an event for the same object twice', () ->
      hifo = HifoStream HifoStream.highest 'value'
      stream = hifo.sorted()
      count = 0
      inputStream = es.through()

      inputStream
      .pipe stream
      .on 'data', (data) ->
        count++

      obj1 = { value: 1 }
      obj2 = { value: 1 }
      inputStream.write obj1
      inputStream.write obj2
      inputStream.write obj1
      assert.equal count, 0
      inputStream.end()
      assert.equal count, 2

    it 'should put new but equal objects before the existing', () ->
      hifo = HifoStream HifoStream.highest 'value'
      stream = hifo.sorted()
      results = []
      inputStream = es.through()

      inputStream
      .pipe stream
      .on 'data', (data) ->
        results.push data

      obj1 = { value: 1 }
      obj2 = { value: 1 }
      inputStream.write obj1
      inputStream.write obj2

      assert.equal results.length, 0
      inputStream.end()
      assert.equal results.length, 2
      assert results.indexOf(obj1) > results.indexOf obj2





  describe 'filter', () ->

    it 'should fill `data` until `size` is reached', () ->
      hifo = HifoStream HifoStream.lowest(), 2
      stream = hifo.filter()
      result = []
      input = piIntStream()

      input.stream
      .pipe stream
      .on 'data', (data) ->
        result.push data

      input.writeNext()
      assert.equal result.length, 1
      input.writeNext()
      assert.equal result.length, 2
      input.writeNext()
      assert.equal result.length, 2

    it 'should filter integers by `lowest`', () ->
      hifo = HifoStream HifoStream.lowest(), 2
      stream = hifo.filter()
      result = []
      input = piIntStream()

      input.stream
      .pipe stream
      .on 'data', (data) ->
        result.push data

      input.writeNext 4
      assert.deepEqual result, [3, 1, 2] # skipped 4

    it 'should filter integers by `highest`', () ->
      hifo = HifoStream HifoStream.highest(), 2
      stream = hifo.filter()
      result = []
      input = piIntStream()

      input.stream
      .pipe stream
      .on 'data', (data) ->
        result.push data

      input.writeNext 4
      assert.deepEqual result, [3, 1, 4] # skipped 2

    it 'should filter objects by `lowest(\'value\')`', () ->
      hifo = HifoStream HifoStream.lowest('value'), 2
      stream = hifo.filter()
      result = []
      input = piObjectStream 'value'

      input.stream
      .pipe stream
      .on 'data', (data) ->
        result.push data

      input.writeNext 4
      assert.deepEqual result, [
        { i: 1, value: 3 }
        { i: 2, value: 1 }
        { i: 4, value: 2 }
      ]

    it 'should filter objects by `lowest(\'a\', \'b\')`', () ->
      hifo = HifoStream HifoStream.lowest('value', 'i'), 4
      stream = hifo.filter()
      result = []
      input = piObjectStream 'value'

      input.stream
      .pipe stream
      .on 'data', (data) ->
        result.push data

      input.writeNext 7
      assert.deepEqual result, [
        { i: 1, value: 3 }
        { i: 2, value: 1 }
        { i: 3, value: 4 }
        { i: 4, value: 2 }
        { i: 7, value: 3 }
      ]

    it 'should filter objects by `highest(\'value\')`', () ->
      hifo = HifoStream HifoStream.highest('value'), 4
      stream = hifo.filter()
      result = []
      input = piObjectStream 'value'

      input.stream
      .pipe stream
      .on 'data', (data) ->
        result.push data

      input.writeNext 8
      assert.deepEqual result, [
        { i: 1, value: 3 }
        { i: 2, value: 1 }
        { i: 3, value: 4 }
        { i: 4, value: 2 }
        { i: 5, value: 6 }
        { i: 6, value: 9 }
        { i: 7, value: 3 } # replaces { i: 1, value: 3 } because it is newer
        { i: 8, value: 7 }
      ]

    it 'should filter objects by `highest(\'a\', \'b\')`', () ->
      hifo = HifoStream HifoStream.highest('value', 'i'), 4
      stream = hifo.filter()
      result = []
      input = piObjectStream 'value'

      input.stream
      .pipe es.through (data) ->
        data.i = 10 - data.i
        @emit 'data', data
      .pipe stream
      .on 'data', (data) ->
        result.push data

      input.writeNext 8
      assert.deepEqual result, [
        { i: 9, value: 3 }
        { i: 8, value: 1 }
        { i: 7, value: 4 }
        { i: 6, value: 2 }
        { i: 5, value: 6 }
        { i: 4, value: 9 }
        # skipped { i: 3, value: 3 }
        { i: 2, value: 7 }
      ]

    it 'should not emit an event for the same number twice', () ->
      hifo = HifoStream HifoStream.highest(), 7
      stream = hifo.filter()
      count = 0
      input = piIntStream()

      input.stream
      .pipe stream
      .on 'data', (data) ->
        count++

      input.writeNext 7
      assert.equal count, 6

    it 'should not emit an event for the same object twice', () ->
      hifo = HifoStream HifoStream.highest 'value'
      stream = hifo.filter()
      count = 0
      inputStream = es.through()

      inputStream
      .pipe stream
      .on 'data', (data) ->
        count++

      obj1 = { value: 1 }
      obj2 = { value: 1 }
      inputStream.write obj1
      inputStream.write obj2
      inputStream.write obj1
      assert.equal count, 2











  describe 'update', () ->

    it 'should fill `data` until `size` is reached', () ->
      hifo = HifoStream HifoStream.lowest(), 2
      stream = hifo.update()
      result = []
      input = piIntStream()

      input.stream
      .pipe stream
      .on 'data', (data) ->
        result = data

      input.writeNext()
      assert.equal result.length, 1
      input.writeNext()
      assert.equal result.length, 2
      input.writeNext()
      assert.equal result.length, 2

    it 'should sort integers by `lowest`', () ->
      hifo = HifoStream HifoStream.lowest(), 3
      stream = hifo.update()
      result = []
      input = piIntStream()

      input.stream
      .pipe stream
      .on 'data', (data) ->
        result = data

      input.writeNext()
      assert.deepEqual result, [3]
      input.writeNext()
      assert.deepEqual result, [1, 3]
      input.writeNext()
      assert.deepEqual result, [1, 3, 4]
      input.writeNext()
      assert.deepEqual result, [1, 2, 3]

    it 'should sort integers by `highest`', () ->
      hifo = HifoStream HifoStream.highest(), 2
      stream = hifo.update()
      result = []
      input = piIntStream()

      input.stream
      .pipe stream
      .on 'data', (data) ->
        result = data

      input.writeNext()
      assert.deepEqual result, [3]
      input.writeNext()
      assert.deepEqual result, [3, 1]
      input.writeNext()
      assert.deepEqual result, [4, 3]
      input.writeNext()
      assert.deepEqual result, [4, 3]

    it 'should sort objects by `lowest(\'value\')`', () ->
      hifo = HifoStream HifoStream.lowest('value'), 3
      stream = hifo.update()
      result = []
      input = piObjectStream 'value'

      input.stream
      .pipe stream
      .on 'data', (data) ->
        result = data

      input.writeNext 7
      assert.deepEqual result, [
        { i: 2, value: 1 }
        { i: 4, value: 2 }
        { i: 7, value: 3 }
      ]

    it 'should sort object `data` by `lowest(\'value\')`', () ->
      hifo = HifoStream HifoStream.lowest('value'), 4
      stream = hifo.update()
      result = []
      input = piObjectStream 'value'

      input.stream
      .pipe stream
      .on 'data', (data) ->
        result = data

      input.writeNext 7
      assert.deepEqual result, [
        { i: 2, value: 1 }
        { i: 4, value: 2 }
        { i: 7, value: 3 }
        { i: 1, value: 3 }
      ]

    it 'should sort object `data` by `lowest(\'a\', \'b\')`', () ->
      hifo = HifoStream HifoStream.lowest('value', 'i'), 4
      stream = hifo.update()
      result = []
      input = piObjectStream 'value'

      input.stream
      .pipe stream
      .on 'data', (data) ->
        result = data

      input.writeNext 7
      assert.deepEqual result, [
        { i: 2, value: 1 }
        { i: 4, value: 2 }
        { i: 1, value: 3 }
        { i: 7, value: 3 }
      ]

    it 'should sort object `data` by `highest(\'value\')`', () ->
      hifo = HifoStream HifoStream.highest('value'), 5
      stream = hifo.update()
      result = []
      input = piObjectStream 'value'

      input.stream
      .pipe stream
      .on 'data', (data) ->
        result = data

      input.writeNext 7
      assert.deepEqual result, [
        { i: 6, value: 9 }
        { i: 5, value: 6 }
        { i: 3, value: 4 }
        { i: 7, value: 3 }
        { i: 1, value: 3 }
      ]

    it 'should sort object `data` by `highest(\'a\', \'b\')`', () ->
      hifo = HifoStream HifoStream.highest('value', 'i'), 5
      stream = hifo.update()
      result = []
      input = piObjectStream 'value'

      input.stream
      .pipe stream
      .on 'data', (data) ->
        result = data

      input.writeNext 7
      assert.deepEqual result, [
        { i: 6, value: 9 }
        { i: 5, value: 6 }
        { i: 3, value: 4 }
        { i: 7, value: 3 }
        { i: 1, value: 3 }
      ]

    it 'should not emit an event for the same number twice', () ->
      hifo = HifoStream HifoStream.highest(), 7
      stream = hifo.update()
      count = 0
      input = piIntStream()

      input.stream
      .pipe stream
      .on 'data', (data) ->
        count++

      input.writeNext 7
      assert.equal count, 6

    it 'should not emit an event for the same object twice', () ->
      hifo = HifoStream HifoStream.highest 'value'
      stream = hifo.update()
      count = 0
      inputStream = es.through()

      inputStream
      .pipe stream
      .on 'data', (data) ->
        count++

      obj1 = { value: 1 }
      obj2 = { value: 1 }
      inputStream.write obj1
      inputStream.write obj2
      inputStream.write obj1
      assert.equal count, 2

    it 'should put new but equal objects before the existing', () ->
      hifo = HifoStream HifoStream.highest 'value'
      stream = hifo.update()
      results = []
      inputStream = es.through()

      inputStream
      .pipe stream
      .on 'data', (data) ->
        results = data

      obj1 = { value: 1 }
      obj2 = { value: 1 }
      inputStream.write obj1
      inputStream.write obj2

      assert.equal results.length, 2
      assert results.indexOf(obj1) > results.indexOf obj2
