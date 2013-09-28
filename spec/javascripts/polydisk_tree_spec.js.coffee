describe 'PolyDiskTree', ->

  tree = null
  beforeEach ->
    tree = PolyDiskTree.create()

  afterEach ->
    tree = null

  describe 'adding 3 root dirs with common path', ->
    beforeEach ->
      tree.get('directories').pushObject Ember.Object.create(relative_path: 'Level1')
      tree.get('directories').pushObject Ember.Object.create(relative_path: 'Level1')
      tree.get('directories').pushObject Ember.Object.create(relative_path: 'Level1')

    it 'creates only one child', ->
      expect( tree.get('root.children.length') ).toEqual(1)

    it 'adds 3 alternatives for that child', ->
      expect( tree.get('root.children.firstObject.alternatives.length') ).toEqual(3)

  describe 'adding two levels of directories, second has duplicate', ->
    beforeEach ->
      tree.get('directories').pushObject Ember.Object.create(relative_path: 'Level1')
      tree.get('directories').pushObject Ember.Object.create(relative_path: 'Level1/Level2')
      tree.get('directories').pushObject Ember.Object.create(relative_path: 'Level1/Level2')

    it 'creates only one direct child', ->
      expect( tree.get('root.children.length') ).toEqual(1)

    it 'creates only one grandchild under the one child', ->
      expect( tree.get('root.children.firstObject.children.length') ).toEqual(1)

    it 'adds only one alternative for the child', ->
      expect( tree.get('root.children.firstObject.alternatives.length') ).toEqual(1)

    it 'adds only 2 alternatives for the grandchild', ->
      expect( tree.get('root.children.firstObject.children.firstObject.alternatives.length') ).toEqual(2)

  describe 'adding a 3-level deep directory, skipping intermediates', ->
    beforeEach ->
      tree.get('directories').pushObject Ember.Object.create(relative_path: 'Level1/Level2/Level3')

    it 'adds no alternatives for intermediates', ->
      expect( tree.get('root.children.firstObject.alternatives.length') ).toEqual(0)
      expect( tree.get('root.children.firstObject.children.firstObject.alternatives.length') ).toEqual(0)

    it 'adds alternative for leaf', ->
      expect( tree.get('root.children.firstObject.children.firstObject.children.firstObject.alternatives.length') ).toEqual(1)

  it 'can specify #directories on creation', ->
    list = Ember.A()
    list.pushObject('given')
    tree = PolyDiskTree.create directories: list
    expect( tree.get('directories') ).toEqual( list )
