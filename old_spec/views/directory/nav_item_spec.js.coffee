describe 'Cataract.DirectoryNavItemView', ->
  view = null
  content = null

  beforeEach ->
    TEST.stubLinkToHelper()
    content = Ember.Object.create(hasSubDirs: false)
    # it's a listView, they are strange with their content.
    view = Cataract.DirectoryNavItemView.create(content: content, controller: content)
    Ember.run ->
      view.append()

  afterEach ->
    Ember.run ->
      view.remove()
    view = null
    TEST.restoreLinkToHelper()

  it "is defined", ->
    expect(view).toBeDefined()

  it "is rendered", ->
    expect(view.$).toBeDefined()
    expect(view.$()).toBeDefined()
    expect(view.$().length).toEqual(1)

  describe 'for missing directory', ->
    beforeEach ->
      Ember.run ->
        content.set 'exists', false

    it "adds warning icon", ->
      expect( view.$('i.icon-warning-sign').length ).toEqual(1)

    it "marks item as missing", ->
      expect( view.$().hasClass('missing') ).toBe(true)

  describe 'for existing directory', ->
    beforeEach ->
      Ember.run ->
        content.set 'exists', true

    it "adds folder icon", ->
      expect( view.$('i.icon-folder-open').length ).toEqual(1)

    it "marks item as existing", ->
      expect( view.$().hasClass('existing') ).toBe(true)
