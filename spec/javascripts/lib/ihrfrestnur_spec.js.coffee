#=require lib/ihrfrestnur

describe 'IhrfRESTnur', ->

  I = Ember.Namespace.create() # namespace for our models and stuff
  window.I = I

  I.Post = IhrfRESTnur.Model.extend
    title: DS.attr 'string'

  I.Comment = IhrfRESTnur.Model.extend
    body: DS.attr 'string'
    post: DS.belongsTo 'I.Post'

  I.Comment.nestedUnder = 'post'

  post = I.Post.createRecord(id: 23)
  comment = I.Comment.createRecord(id: 42, post: post)
    

  describe 'URL generation', ->
    adapter = IhrfRESTnur.Adapter.create()

    describe 'without namespace', ->

      beforeEach ->
        adapter.set 'namespace', null

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
