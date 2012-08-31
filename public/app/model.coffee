# Source: http://searchco.de/codesearch/view/10365461
# with to_i fix

Model =
  name: "model"
  init: ->
    @_id = 0
    @_data = []
    @_deserialize()
    this

  create: (attributes, save) ->
    attributes.id = @_newId()
    item = @_data[(@_data.push(attributes)) - 1]
    @save()  if save isnt false
    @_clone item

  first: ->
    @_clone @_data[0]

  last: ->
    @_clone _data[@_data.length - 1]

  get: (id) ->
    id = @_to_i(id)
    @_clone @_get(id)

  getAll: ->
    @_clone @_data

  filter: (attribute, value) ->
    @_clone @_filter(attribute, value)

  multiFilter: (filters) ->
    @_clone @_multiFilter(filter)

  update: (id, attributes, save) ->
    item = @_get(id) or false
    if item
      @_mixin item, attributes
      @save()  if save isnt false
    item

  destroy: (id, save) ->
    @_data.splice @_indexOf(id), 1
    @save()  if save isnt false
    true

  destroyAll: (save) ->
    @_data = []
    @save()  if save isnt false
    true

  save: ->
    @_serialize()
    true

  _first: ->
    @_data[0]

  _last: ->
    _data[@_data.length - 1]

  _get: (id) ->
    @_filter("id", id)[0]

  _filter: (attribute, value) ->
    items = []
    key = undefined
    item = undefined
    undefValue = (typeof value is "undefined")
    for key of @_data
      if @_data.hasOwnProperty(key)
        item = @_data[key]
        items.push item  if undefValue or item[attribute] is value
    items

  _multiFilter: (filters) ->
    items = []
    key = undefined
    attribute = undefined
    item = undefined
    for key of @_data
      if @_data.hasOwnProperty(key)
        item = @_data[key]
        for attribute of filters
          items.push item  if filters[attribute] is item[attribute]  if filters.hasOwnProperty(attribute)
    items

  _indexOf: (id) ->
    @_data.indexOf @_get(id)

  _serialize: ->
    data =
      prevId: @_id
      data: @_data

    localStorage[@name] = JSON.stringify(data)

  _deserialize: ->
    data = localStorage[@name]
    if data
      data = JSON.parse(data)
      @_id = data.prevId
      @_data = data.data

  _to_i: (val) ->
    parseInt(val, 10)

  _newId: ->
    @_id++

  _mixin: (to, from) ->
    for key of from
      to[key] = from[key]  if from.hasOwnProperty(key)

  _clone: (obj) ->
    type = Object::toString.call(obj)
    cloned = obj
    if type is "[object Object]"
      cloned = {}
      for key of obj
        obj.hasOwnProperty(key) and (cloned[key] = @_clone(obj[key]))
    else if type is "[object Array]"
      cloned = []
      index = 0
      length = obj.length

      while index < length
        cloned[index] = @_clone(obj[index])
        index++
    cloned

# http://javascript.crockford.com/prototypal.html
if typeof Object.create isnt "function"
  Object.create = (o) ->
    F = ->
    F:: = o
    new F()

this.Model = Model