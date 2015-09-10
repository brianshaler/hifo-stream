mocha =		require 'mocha'
assert =	require 'assert'

HifoStream =		require '../index.js'





describe 'index', () ->



	describe 'lowest', () ->

		it 'should sort numeric values correctly', () ->
			sort = HifoStream.lowest()
			assert 0 > sort 4, 5
			assert 0 < sort -1, -2

		it 'should sort object values correctly', () ->
			sort = HifoStream.lowest 'test'
			assert 0 > sort { test: 4 }, { test: 5 }
			assert 0 < sort { test: -1 }, { test: -2 }



	describe 'highest', () ->

		it 'should sort numeric values correctly', () ->
			sort = HifoStream.highest()
			assert 0 < sort 4, 5
			assert 0 > sort -1, -2

		it 'should sort object values correctly', () ->
			sort = HifoStream.highest 'test'
			assert 0 < sort { test: 4 }, { test: 5 }
			assert 0 > sort { test: -1 }, { test: -2 }
