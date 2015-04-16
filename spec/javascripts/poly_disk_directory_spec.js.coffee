describe 'Cataract.PolyDiskDirectory', ->

  describe '.create', ->
    it 'accepts relative path', ->
      dir = Cataract.PolyDiskDirectory.create(relativePath: 'foo/bar')

      expect( dir.get('relativePath') ).toEqual( 'foo/bar' )

  describe '#getOrBuildChildByNameOnDisk', ->
    l1 = null
    l2 = null
    beforeEach ->
      l1 = Cataract.PolyDiskDirectory.create()
    afterEach ->
      l1 = null
      l2 = null

    it 'creates new child if none found for name', ->
      l2 = l1.getOrBuildChildByNameOnDisk('foo')
      expect( l1.get('children.length') ).toEqual(1)
      expect( l1.get('children.firstObject') ).toEqual( l2 )

    it 'finds child if already present', ->
      l1.getOrBuildChildByNameOnDisk('foo')
      l1.getOrBuildChildByNameOnDisk('foo')
      expect( l1.get('children.length') ).toEqual(1)

    it 'assigns correct path as root', ->
      l1.set('relativePath',  '')
      l2 = l1.getOrBuildChildByNameOnDisk('sub')
      expect( l2.get('relativePath') ).toEqual('sub')

    it 'assigns correct path as sub', ->
      l1.set('relativePath',  'l1')
      l2 = l1.getOrBuildChildByNameOnDisk('l2')
      expect( l2.get('relativePath') ).toEqual('l1/l2')





