describe 'PolyDiskTree', ->

  tree = null
  beforeEach ->
    tree = PolyDiskTree.create()

  afterEach ->
    tree = null

  it 'joins root children with common path', ->
    root1 = Ember.Object.create(relative_path: 'Level1')
    root2 = Ember.Object.create(relative_path: 'Level1')
    root3 = Ember.Object.create(relative_path: 'Level1')
    tree.get('directories').pushObject root1
    tree.get('directories').pushObject root2
    tree.get('directories').pushObject root3
    expect( tree.get('root.children.length') ).toEqual(1)
    expect( tree.get('root.children.firstObject.alternatives.length') ).toEqual(3)

  #it 'joins root grandchildren with common path', ->
  #  root = Ember.Object.create(relative_path: 'Level1')
  #  level2 = Ember.Object.create(relative_path: 'Level1/Level2')
  #  tree.get('directories').pushObject root
  #  tree.get('directories').pushObject level2
  #  expect( tree.get('root.children.length') ).toEqual(1)
  #  expect( tree.get('root.children.firstObject.children.length') ).toEqual(1)
  #  expect( tree.get('root.children.firstObject.children.firstObject.alternatives.length') ).toEqual(1)

