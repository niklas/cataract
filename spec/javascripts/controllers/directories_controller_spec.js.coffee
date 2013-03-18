describe 'Cataract.DirectoriesController', ->
  controller = directory = store = null
  found = null

  beforeEach ->
    Ember.testing = false

    store = DS.Store.create
      revision: 11
      adapter: 'DS.FixtureAdapter'

    Cataract.Disk.FIXTURES = [
      { id: 1, name: 'a Disk' }
    ]
    Cataract.Directory.FIXTURES = [ ]


    controller = Cataract.DirectoriesController.create
      unfilteredContent: store.find(Cataract.Directory)

  findDisk = (id) -> store.find(Cataract.Disk, id)

  afterEach ->
    controller = disk = directory = null
    found = null

  it "finds disk through store", ->
    runs ->
      found = findDisk(1)
    waitsFor (->
      found.get('name') == 'a Disk'
    ), 'is found', 100

  # For crying out loud, testing the filteredContent is a PITA

  # describe '#filteredContent', ->
  #   beforeEach ->
  #     controller.set 'disk', findDisk(1)

  #   it "includes Directories on given disk", ->
  #     runs ->
  #       Cataract.Directory.FIXTURES.addObject
  #         id: 999
  #         disk: findDisk(1)
  #       found = controller.get('filteredContent')
  #     waitsFor (->
  #       found.get('length') == 1
  #     ), 'filtering directories', 100

  #   it "excludes Directories on other disks", ->
  #     Ember.run ->
  #       other_disk = Cataract.Disk.createRecord()
  #       directory = Cataract.Directory.createRecord(disk: other_disk)
  #     expect( controller.get('filteredContent')[0] ).toBeNull()

  #   it "includes roots", ->
  #     Ember.run ->
  #       directory = Cataract.Directory.createRecord(disk: disk, parent: null)
  #     expect( controller.get('filteredContent').get(0) ).toEqual( directory )

  #   it "includes leafs", ->
  #     Ember.run ->
  #       parent = Cataract.Directory.create()
  #       directory = Cataract.Directory.createRecord(disk: disk, parent: parent)
  #     expect( controller.get('filteredContent').get(0) ).toEqual( directory )

  # describe '#roots', ->
  #   it "includes Directories without parent"
  #   it "excludes Directories with parent"
  #   it "is filtered by disk"
