# IhrfRESTnur
#
# A more RESTful store adapter for ember-data.
#
# Converted original DS.RESTAdapter (0b246b9780) to CoffeeScript.

IhrfRESTnur = Ember.Namespace.create()

get = Ember.get
set = Ember.set
serializer = DS.Serializer.create(
  keyForBelongsTo: (type, name) ->
    @keyForAttributeName(type, name) + "_id"

  keyForAttributeName: (type, name) ->
    Ember.String.decamelize name
)
IhrfRESTnur.Adapter = DS.Adapter.extend(
  bulkCommit: false
  serializer: serializer
  shouldCommit: (record) ->
    true  if record.isCommittingBecause("attribute") or record.isCommittingBecause("belongsTo")

  createRecord: (store, type, record) ->
    root = @rootForType(type)
    data = {}
    data[root] = @toJSON(record,
      includeId: true
    )
    @ajax @buildURL(root), "POST",
      data: data
      context: this
      success: (json) ->
        @didCreateRecord store, type, record, json


  didCreateRecord: (store, type, record, json) ->
    root = @rootForType(type)
    @sideload store, type, json, root
    store.didSaveRecord record, json[root]

  createRecords: (store, type, records) ->
    return @_super(store, type, records)  if get(this, "bulkCommit") is false
    root = @rootForType(type)
    plural = @pluralize(root)
    data = {}
    data[plural] = []
    records.forEach ((record) ->
      data[plural].push @toJSON(record,
        includeId: true
      )
    ), this
    @ajax @buildURL(root), "POST",
      data: data
      context: this
      success: (json) ->
        @didCreateRecords store, type, records, json


  didCreateRecords: (store, type, records, json) ->
    root = @pluralize(@rootForType(type))
    @sideload store, type, json, root
    store.didSaveRecords records, json[root]

  updateRecord: (store, type, record) ->
    id = get(record, "id")
    root = @rootForType(type)
    data = {}
    data[root] = @toJSON(record)
    @ajax @buildURL(root, id), "PUT",
      data: data
      context: this
      success: (json) ->
        @didUpdateRecord store, type, record, json


  didUpdateRecord: (store, type, record, json) ->
    root = @rootForType(type)
    @sideload store, type, json, root
    store.didSaveRecord record, json and json[root]

  updateRecords: (store, type, records) ->
    return @_super(store, type, records)  if get(this, "bulkCommit") is false
    root = @rootForType(type)
    plural = @pluralize(root)
    data = {}
    data[plural] = []
    records.forEach ((record) ->
      data[plural].push record.toJSON()
    ), this
    @ajax @buildURL(root, "bulk"), "PUT",
      data: data
      context: this
      success: (json) ->
        @didUpdateRecords store, type, records, json


  didUpdateRecords: (store, type, records, json) ->
    root = @pluralize(@rootForType(type))
    @sideload store, type, json, root
    store.didSaveRecords records, json[root]

  deleteRecord: (store, type, record) ->
    id = get(record, "id")
    root = @rootForType(type)
    @ajax @buildURL(root, id), "DELETE",
      context: this
      success: (json) ->
        @didDeleteRecord store, type, record, json


  didDeleteRecord: (store, type, record, json) ->
    @sideload store, type, json  if json
    store.didSaveRecord record

  deleteRecords: (store, type, records) ->
    return @_super(store, type, records)  if get(this, "bulkCommit") is false
    root = @rootForType(type)
    plural = @pluralize(root)
    data = {}
    data[plural] = []
    records.forEach (record) ->
      data[plural].push get(record, "id")

    @ajax @buildURL(root, "bulk"), "DELETE",
      data: data
      context: this
      success: (json) ->
        @didDeleteRecords store, type, records, json


  didDeleteRecords: (store, type, records, json) ->
    @sideload store, type, json  if json
    store.didSaveRecords records

  find: (store, type, id) ->
    root = @rootForType(type)
    @ajax @buildURL(root, id), "GET",
      success: (json) ->
        @sideload store, type, json, root
        store.load type, json[root]


  findMany: (store, type, ids) ->
    root = @rootForType(type)
    plural = @pluralize(root)
    @ajax @buildURL(root), "GET",
      data:
        ids: ids

      success: (json) ->
        @sideload store, type, json, plural
        store.loadMany type, json[plural]


  findAll: (store, type) ->
    root = @rootForType(type)
    plural = @pluralize(root)
    @ajax @buildURL(root), "GET",
      success: (json) ->
        @sideload store, type, json, plural
        store.loadMany type, json[plural]


  findQuery: (store, type, query, recordArray) ->
    root = @rootForType(type)
    plural = @pluralize(root)
    @ajax @buildURL(root), "GET",
      data: query
      success: (json) ->
        @sideload store, type, json, plural
        recordArray.load json[plural]


  
  # HELPERS
  plurals: {}
  
  # define a plurals hash in your subclass to define
  # special-case pluralization
  pluralize: (name) ->
    @plurals[name] or name + "s"

  rootForType: (type) ->
    return type.url  if type.url
    
    # use the last part of the name as the URL
    parts = type.toString().split(".")
    name = parts[parts.length - 1]
    name.replace(/([A-Z])/g, "_$1").toLowerCase().slice 1

  ajax: (url, type, hash) ->
    hash.url = url
    hash.type = type
    hash.dataType = "json"
    hash.contentType = "application/json; charset=utf-8"
    hash.context = this
    hash.data = JSON.stringify(hash.data)  if hash.data and type isnt "GET"
    jQuery.ajax hash

  sideload: (store, type, json, root) ->
    sideloadedType = undefined
    mappings = undefined
    loaded = {}
    loaded[root] = true
    for prop of json
      continue  unless json.hasOwnProperty(prop)
      continue  if prop is root
      sideloadedType = type.typeForAssociation(prop)
      unless sideloadedType
        mappings = get(this, "mappings")
        Ember.assert "Your server returned a hash with the key " + prop + " but you have no mappings", !!mappings
        sideloadedType = get(mappings, prop)
        sideloadedType = get(window, sideloadedType)  if typeof sideloadedType is "string"
        Ember.assert "Your server returned a hash with the key " + prop + " but you have no mapping for it", !!sideloadedType
      @sideloadAssociations store, sideloadedType, json, prop, loaded

  sideloadAssociations: (store, type, json, prop, loaded) ->
    loaded[prop] = true
    get(type, "associationsByName").forEach ((key, meta) ->
      key = meta.key or key
      key = @pluralize(key)  if meta.kind is "belongsTo"
      @sideloadAssociations store, meta.type, json, key, loaded  if json[key] and not loaded[key]
    ), this
    @loadValue store, type, json[prop]

  loadValue: (store, type, value) ->
    if value instanceof Array
      store.loadMany type, value
    else
      store.load type, value

  buildURL: (record, suffix) ->
    url = [""]
    Ember.assert "Namespace URL (" + @namespace + ") must not start with slash", not @namespace or @namespace.toString().charAt(0) isnt "/"
    Ember.assert "Record URL (" + record + ") must not start with slash", not record or record.toString().charAt(0) isnt "/"
    Ember.assert "URL suffix (" + suffix + ") must not start with slash", not suffix or suffix.toString().charAt(0) isnt "/"
    url.push @namespace  if @namespace isnt `undefined`
    url.push @pluralize(record)
    url.push suffix  if suffix isnt `undefined`
    url.join "/"
)


window.IhrfRESTnur = IhrfRESTnur
