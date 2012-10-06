Cataract.MoveTorrentView = Ember.View.extend
  template: Ember.Handlebars.compile """
    {{view Cataract.SelectDirectoryField selectionBinding="move.targetDirectory" label="directory"}}
    {{view Cataract.SelectDiskField selectionBinding="move.targetDisk" label="Disk"}}
  """

