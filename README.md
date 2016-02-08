parseurl
========

> Get the first event in a set of event emitters and event pairs, then clean up after itself.

This was modified from the node.js version at [jonathanong/ee-first](https://github.com/jonathanong/ee-first).

### Install

```sh
$ lit install james2doyle/ee-first
```

### Usage

```lua
local first = require('ee-first')
```

#### first(arr, listener)

Invoke listener on the first event from the list specified in arr. arr is an array of arrays, with each array in the format [EventEmitter, ...event]. listener will be called only once, the first time any of the given events are emitted. If error is one of the listened events, then if that fires first, the listener will be given the err argument.

The listener is invoked as listener(err, ee, event, args), where err is the first argument emitted from an error event, if applicable; ee is the event emitter that fired; event is the string event name that fired; and args is an array of the arguments that were emitted on the event.

```lua
local ee1 = EventEmitter:new()
local ee2 = EventEmitter:new()

first({
  {ee1, 'close', 'end', 'error'},
  {ee2, 'error'}
}, function (err, ee, event, args)
  // listener invoked
end)
```

#### :cancel()

The group of listeners can be cancelled before being invoked and have all the event listeners removed from the underlying event emitters.

```lua
var thunk = first({
  {ee1, 'close', 'end', 'error'},
  {ee2, 'error'}
}, function (err, ee, event, args)
  // listener invoked
end)

// cancel and clean up
thunk:cancel()
```