# IhrfRESTnur
#
# A more RESTful store adapter for ember-data.
#
# Converted original DS.RESTAdapter (master dad611cd7e0b) to CoffeeScript.

IhrfRESTnur = Ember.Namespace.create()

IhrfRESTnur.Model = DS.Model.extend
  urlComponents: ->
    pre = @constructor.urlComponents(this)
    pre.push this unless Ember.none(@get('id')) # persisted?
    pre

  toParam: -> @get('id')

# TODO extract this to something similar to ActiveModel::Name
IhrfRESTnur.Model.reopenClass
  urlComponents: (record) ->
    if @nestedUnder
      property = @metaForProperty(@nestedUnder)
      Ember.assert "expected #{@nestedUnder} to be a property of #{@toString()}, but was #{property}", !!property
      Ember.assert "expected #{@nestedUnder} to be a belongsTo association of #{@toString()}", property.isAssociation and property.kind is 'belongsTo'
      if record? and nested = record.get(property.key)
        pre = nested.urlComponents()
        pre.push this
        pre
      else
        [ property.type, this ] # should never happen (TM)
    else
      [ this ]
  toParam: ->
    return @url if @url
    @pluralBaseName()

  singularBaseName: (adapter) ->
    parts = @toString().split(".")
    name = parts[parts.length - 1]
    name.replace(/([A-Z])/g, "_$1").toLowerCase().slice 1

  pluralBaseName: (adapter) ->
    singular = @singularBaseName()
    adapter?.pluralize[singular] or singular + 's'


get = Ember.get
set = Ember.set
IhrfRESTnur.Adapter = DS.Adapter.extend(
  bulkCommit: false
  createRecord: (store, type, record) ->
    data = {}
    data[type.singularBaseName()] = record.toJSON()
    @ajax @urlFor(record), "POST",
      data: data
      context: this
      success: (json) ->
        @didCreateRecord store, type, record, json

  didCreateRecord: (store, type, record, json) ->
    root = type.singularBaseName()
    @sideload store, type, json, root
    store.didCreateRecord record, json[root]

  createRecords: (store, type, records) ->
    return @_super(store, type, records)  if get(this, "bulkCommit") is false
    root = type.singularBaseName()
    plural = type.pluralBaseName()
    data = {}
    data[plural] = records.map((record) ->
      record.toJSON()
    )
    @ajax @buildURL(root), "POST",
      data: data
      context: this
      success: (json) ->
        @didCreateRecords store, type, records, json


  didCreateRecords: (store, type, records, json) ->
    root = type.pluralBaseName()
    @sideload store, type, json, root
    store.didCreateRecords type, records, json[root]

  updateRecord: (store, type, record) ->
    data = {}
    data[type.singularBaseName()] = record.toJSON()
    @ajax @urlFor(record), "PUT",
      data: data
      context: this
      success: (json) ->
        @didUpdateRecord store, type, record, json


  didUpdateRecord: (store, type, record, json) ->
    root = type.singularBaseName()
    @sideload store, type, json, root
    store.didUpdateRecord record, json and json[root]

  updateRecords: (store, type, records) ->
    return @_super(store, type, records)  if get(this, "bulkCommit") is false
    root = type.singularBaseName()
    plural = type.pluralBaseName()
    data = {}
    data[plural] = records.map((record) ->
      record.toJSON()
    )
    @ajax @buildURL(root, "bulk"), "PUT",
      data: data
      context: this
      success: (json) ->
        @didUpdateRecords store, type, records, json


  didUpdateRecords: (store, type, records, json) ->
    root = type.pluralBaseName()
    @sideload store, type, json, root
    store.didUpdateRecords records, json[root]

  deleteRecord: (store, type, record) ->
    id = get(record, "id")
    root = type.singularBaseName()
    @ajax @buildURL(root, id), "DELETE",
      context: this
      success: (json) ->
        @didDeleteRecord store, type, record, json


  didDeleteRecord: (store, type, record, json) ->
    @sideload store, type, json  if json
    store.didDeleteRecord record

  deleteRecords: (store, type, records) ->
    return @_super(store, type, records)  if get(this, "bulkCommit") is false
    root = type.singularBaseName()
    plural = type.pluralBaseName()
    data = {}
    data[plural] = records.map((record) ->
      get record, "id"
    )
    @ajax @buildURL(root, "bulk"), "DELETE",
      data: data
      context: this
      success: (json) ->
        @didDeleteRecords store, type, records, json


  didDeleteRecords: (store, type, records, json) ->
    @sideload store, type, json  if json
    store.didDeleteRecords records

  find: (store, type, id) ->
    root = type.singularBaseName()
    @ajax @buildURL(root, id), "GET",
      success: (json) ->
        @sideload store, type, json, root
        store.load type, json[root]


  findMany: (store, type, ids) ->
    root = type.singularBaseName()
    plural = type.pluralBaseName()
    @ajax @buildURL(root), "GET",
      data:
        ids: ids

      success: (json) ->
        @sideload store, type, json, plural
        store.loadMany type, json[plural]


  findAll: (store, type) ->
    root = type.singularBaseName()
    plural = type.pluralBaseName()
    @ajax @buildURL(root), "GET",
      success: (json) ->
        @sideload store, type, json, plural
        store.loadMany type, json[plural]


  findQuery: (store, type, query, recordArray) ->
    root = type.singularBaseName()
    plural = type.pluralBaseName()
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

  urlFor: (record, suffix) ->
    url = [""]
    Ember.assert "Namespace URL (" + @namespace + ") must not start with slash", not @namespace or @namespace.toString().charAt(0) isnt "/"
    Ember.assert "URL suffix (" + suffix + ") must not start with slash", not suffix or suffix.toString().charAt(0) isnt "/"
    url.push @namespace if @namespace?

    # get, flatten and parameterize record/type relevant components of url
    urlComponents = Array.prototype.concat.apply([], record.urlComponents())
    for component in urlComponents
      Ember.assert "Record URL component must be present", !!component
      param = component.toParam()
      Ember.assert "Record URL param for #{component} must be present", !!param
      Ember.assert "Record URL param for #{component} must not start with slash", param.toString().charAt(0) isnt "/"
      url.pushObject param

    url.push suffix if suffix?
    url.join "/"
)

window.IhrfRESTnur = IhrfRESTnur
