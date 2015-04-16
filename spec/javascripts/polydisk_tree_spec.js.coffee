describe 'Cataract.PolyDiskTreeMixin', ->

  klass = Ember.Object.extend(Cataract.PolyDiskTreeMixin)
  tree = null
  beforeEach ->
    tree = klass.create()

  afterEach ->
    tree = null

  it 'can be created', ->
    expect( tree ).toNotEqual(null)

  it 'has directories collection', ->
    dirs = tree.get('directories')
    expect( dirs ).toNotEqual(undefined)

  describe 'adding 3 root dirs with common path', ->
    beforeEach ->
      dirs = tree.get('directories')
      dirs.pushObject Ember.Object.create(relativePath: 'Level1')
      dirs.pushObject Ember.Object.create(relativePath: 'Level1')
      dirs.pushObject Ember.Object.create(relativePath: 'Level1')

    it 'creates only one child', ->
      expect( tree.get('tree.root.children.length') ).toEqual(1)

    it 'adds 3 alternatives for that child', ->
      expect( tree.get('tree.root.children.firstObject.alternatives.length') ).toEqual(3)

    it 'sets a reference back to the poly on each alternative', ->
      poly = tree.get('tree.root.children.firstObject')
      expect( poly ).not.toBe(null)
      poly.get('alternatives').forEach (alt)->
        expect( alt.get('poly') ).toEqual( poly )

  describe 'adding two levels of directories, second has duplicate', ->
    beforeEach ->
      tree.get('directories').pushObject Ember.Object.create(relativePath: 'Level1')
      tree.get('directories').pushObject Ember.Object.create(relativePath: 'Level1/Level2')
      tree.get('directories').pushObject Ember.Object.create(relativePath: 'Level1/Level2')

    it 'creates only one direct child', ->
      expect( tree.get('tree.root.children.length') ).toEqual(1)

    it 'creates only one grandchild under the one child', ->
      expect( tree.get('tree.root.children.firstObject.children.length') ).toEqual(1)

    it 'adds only one alternative for the child', ->
      expect( tree.get('tree.root.children.firstObject.alternatives.length') ).toEqual(1)

    it 'adds only 2 alternatives for the grandchild', ->
      expect( tree.get('tree.root.children.firstObject.children.firstObject.alternatives.length') ).toEqual(2)

  describe 'adding a 3-level deep directory, skipping intermediates', ->
    beforeEach ->
      tree.get('directories').pushObject Ember.Object.create(relativePath: 'Level1/Level2/Level3')

    it 'adds no alternatives for intermediates', ->
      expect( tree.get('tree.root.children.firstObject.alternatives.length') ).toEqual(0)
      expect( tree.get('tree.root.children.firstObject.children.firstObject.alternatives.length') ).toEqual(0)

    it 'adds alternative for leaf', ->
      expect( tree.get('tree.root.children.firstObject.children.firstObject.children.firstObject.alternatives.length') ).toEqual(1)

  it 'can specify #directories on creation', ->
    list = Ember.A()
    list.pushObject('given')
    tree = klass.create directories: list
    expect( tree.get('directories') ).toEqual( list )
