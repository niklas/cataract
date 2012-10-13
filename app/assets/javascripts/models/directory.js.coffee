Cataract.Directory = DS.Model.extend
  name: DS.attr('string')
  path: DS.attr('string')
  torrents: DS.hasMany('Cataract.Torrent')
  disk: DS.belongsTo('Cataract.Disk')
  isExisting: DS.attr('boolean')
  cssClass: 'directory'
  parentId: DS.attr 'number'
  parent: DS.belongsTo('Cataract.Directory')
  children: (->
    me = this
    Cataract.store.filter Cataract.Directory, (dir) ->
      dir = dir.record if dir.record?
      me.get('id') == dir.get('parentId')
  ).property('Cataract.directories.@each.parentId')
  active: (-> this == Cataract.get('currentDirectory') ).property('Cataract.currentDirectory')
  showSubDirs: DS.attr 'boolean'
  hasSubDirs:(->
    @get('showSubDirs') and @get('children.length') > 0
  ).property('children', 'showSubDirs')

Cataract.Directory.reopenClass
  url: 'directory'
