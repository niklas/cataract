describe 'PolyDiskTree', ->

  it 'joins roots to one', ->
    tree = PolyDiskTree.create()
    root1 = Ember.Object.create(relative_path: 'Level1')
    root2 = Ember.Object.create(relative_path: 'Level1')
    root3 = Ember.Object.create(relative_path: 'Level1')
    tree.get('directories').pushObject root1
    tree.get('directories').pushObject root2
    tree.get('directories').pushObject root3
    expect( tree.get('root.alternatives.length') ).toEqual(3)

  it 'sorts in children, grouped by common parent'
