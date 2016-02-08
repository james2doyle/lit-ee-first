local EventEmitter = require('core').Emitter
local first = require('./init')

local ee1 = EventEmitter:new()
local ee2 = EventEmitter:new()
local ee3 = EventEmitter:new()

local function should_emit_the_first_event ()
  first({
    {ee1, 'a', 'b', 'c'},
    {ee2, 'a', 'b', 'c'},
    {ee3, 'a', 'b', 'c'},
  }, function (err, ee, event, args)
    assert(err == nil)
    assert(event, 'b')
    assert(args, {1, 2, 3})
    assert(ee, ee2)
  end)

  ee2:emit('b', 1, 2, 3)
end

should_emit_the_first_event()

local function should_return_an_error_if_event_equals_error ()
  first({
    {ee1, 'error', 'b', 'c'},
    {ee2, 'error', 'b', 'c'},
    {ee3, 'error', 'b', 'c'}
  }, function (err, ee, event, args)
    assert(err, 'boom')
    assert(ee, ee3)
    assert(event, 'error')
  end)

  ee3:emit('error', 'boom')
end

should_return_an_error_if_event_equals_error()

local function should_cleanup_after_itself ()
  first({
    {ee1, 'a', 'b', 'c'},
    {ee2, 'a', 'b', 'c'},
    {ee3, 'a', 'b', 'c'}
  }, function (err, ee, event, args)
    assert(err == nil)
    local ees = {ee1, ee2, ee3}
    local ops = {'a', 'b', 'c'}
    for i,ee in ipairs(ees) do
      for j,event in ipairs(ops) do
        assert(#ee:listeners(event) == 0)
      end
    end
  end)

  ee1:emit('a')
end

should_cleanup_after_itself()

local function should_return_a_thunk ()
  local thunk = first({
    {ee1, 'a', 'b', 'c'},
    {ee2, 'a', 'b', 'c'},
    {ee3, 'a', 'b', 'c'}
  })
  thunk:done(function (err, ee, event, args)
    assert(err == nil)
    assert(ee, ee2)
    assert(event, 'b')
    assert(args, {1, 2, 3})
  end)

  ee2:emit('b', 1, 2, 3)
end

should_return_a_thunk()


local timer = require('timer')

local function should_not_emit_after_thunk_cancel()
  local thunk = first({
    {ee1, 'a', 'b', 'c'},
    {ee2, 'a', 'b', 'c'},
    {ee3, 'a', 'b', 'c'}
  })
  thunk:done(function ()
    assert(false)
  end)

  thunk:cancel()

  ee2:emit('b', 1, 2, 3)

  timer.setTimeout(10, function()
    assert(true)
  end)
end

should_not_emit_after_thunk_cancel()

local function should_cleanup_after_thunk_cancel()
  local thunk = first({
    {ee1, 'a', 'b', 'c'},
    {ee2, 'a', 'b', 'c'},
    {ee3, 'a', 'b', 'c'}
  })

  thunk:cancel()

  local ees = {ee1, ee2, ee3}
  local ops = {'a', 'b', 'c'}
  for i,ee in ipairs(ees) do
    for j,event in ipairs(ops) do
      assert(#ee:listeners(event) == 0)
    end
  end
end

should_cleanup_after_thunk_cancel()