describe 'PolyDiskDirectory', ->

  describe '.create', ->
    it 'accepts relative path', ->
      dir = PolyDiskDirectory.create(relative_path: 'foo/bar')

      expect( dir.get('relative_path') ).toEqual( 'foo/bar' )

  describe '#getOrBuildChildByName', ->
    l1 = null
    l2 = null
    beforeEach ->
      l1 = PolyDiskDirectory.create()
    afterEach ->
      l1 = null
      l2 = null

    it 'creates new child if none found for name', ->
      l2 = l1.getOrBuildChildByName('foo')
      expect( l1.get('children.length') ).toEqual(1)
      expect( l1.get('children.firstObject') ).toEqual( l2 )

    it 'finds child if already present', ->
      l1.getOrBuildChildByName('foo')
      l1.getOrBuildChildByName('foo')
      expect( l1.get('children.length') ).toEqual(1)

    it 'assigns correct path as root', ->
      l1.set('relative_path',  '')
      l2 = l1.getOrBuildChildByName('sub')
      expect( l2.get('relative_path') ).toEqual('sub')

    it 'assigns correct path as sub', ->
      l1.set('relative_path',  'l1')
      l2 = l1.getOrBuildChildByName('l2')
      expect( l2.get('relative_path') ).toEqual('l1/l2')





