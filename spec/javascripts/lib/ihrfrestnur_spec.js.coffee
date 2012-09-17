#=require lib/ihrfrestnur

describe 'IhrfRESTnur', ->
  adapter = store = post = newPost = comment = newComment = null

  beforeEach ->
    I = Ember.Namespace.create() # namespace for our models and stuff
    window.I = I

    I.Post = IhrfRESTnur.Model.extend
      title: DS.attr 'string'

    I.Comment = IhrfRESTnur.Model.extend
      body: DS.attr 'string'
      post: DS.belongsTo 'I.Post'

    adapter = IhrfRESTnur.Adapter.create()

    I.Comment.nestedUnder = 'post'
    store = DS.Store.create
      revision: 4
      adapter: adapter

    post =       store.createRecord I.Post, id: 23
    newPost =    store.createRecord I.Post, title: 'a post'
    comment =    store.createRecord I.Comment, id: 42, post: post, body: 'yeah'
    newComment = store.createRecord I.Comment, post: post, body: 'wow'

    spyOn(adapter, 'ajax')
    

  describe 'URL generation', ->

    describe 'without namespace', ->

      beforeEach ->
        adapter.set 'namespace', null

      describe 'for unsaved record (missing id)', ->
        it "should build URL for collection", ->
          expect( adapter.urlFor(newPost) ).toEqual('/posts')

        it "should build URL for nested collection", ->
          expect( adapter.urlFor(newComment) ).toEqual('/posts/23/comments')

      describe 'for saved record (having id)', ->
        it "should build URL for existing toplevel record [show]", ->
          expect( adapter.urlFor(post) ).toEqual('/posts/23')

        it "should build URL for existing nested record [show]", ->
          expect( adapter.urlFor(comment) ).toEqual('/posts/23/comments/42')


    describe 'with namespace', ->
      namespace = 'a/nested/namespace'

      beforeEach ->
        adapter.set 'namespace', namespace

      it "should build URL for existing toplevel record [show]", ->
        expect( adapter.urlFor(post) ).toEqual('/a/nested/namespace/posts/23')

      it "should build URL for existing nested record [show]", ->
        expect( adapter.urlFor(comment) ).toEqual('/a/nested/namespace/posts/23/comments/42')

  xit "should accept custom pluralizations"

  describe 'resourcing', ->
    url   = jasmine.createSpy("the url")

    beforeEach ->
      spyOn(adapter, 'urlFor').andReturn(url)

    it "should POST to collection URL to create new record", ->
      adapter.createRecord(store, I.Post, newPost)
      expect(adapter.urlFor).toHaveBeenCalledWith(newPost)
      expect(adapter.ajax).toHaveBeenCalledWith(url, 'POST', jasmine.any(Object))


    it "should PUT to record URL for the record to update it", ->
      adapter.updateRecord(store, I.Post, post)
      expect(adapter.urlFor).toHaveBeenCalledWith(post)
      expect(adapter.ajax).toHaveBeenCalledWith(url, 'PUT', jasmine.any(Object))


