#=require lib/ihrfrestnur

describe 'IhrfRESTnur', ->

  I = {} # namespace for our models and stuff

  I.Post = DS.Model.extend
    title: DS.attr 'string'

  I.Comment = DS.Model.extend
    body: DS.attr 'string'
    post: DS.belongsTo 'I.Post'

  post = I.Post.createRecord(id: 23)
  comment = I.Comment.createRecord(id: 42, post: post)
    

  describe 'URL generation', ->

    adapter = IhrfRESTnur.Adapter.create()

    describe 'without namespace', ->

      beforeEach ->
        adapter.set 'namespace', null

      it "should build URL for existing record [show]", ->
        expect( adapter.buildURL(post) ).toEqual('/posts/23')

      it "should build URL for existing record [show]", ->
        expect( adapter.buildURL(comment) ).toEqual('/posts/23/comments/42')


    describe 'with namespace', ->
      namespace = 'a/nested/namespace'

      beforeEach ->
        adapter.set 'namespace', namespace

      it "should build URL for existing record [show]", ->
        expect( adapter.buildURL(post) ).toEqual('/a/nested/namespace/posts/23')

      it "should build URL for existing record [show]", ->
        expect( adapter.buildURL(comment) ).toEqual('/a/nested/namespace/posts/23/comments/42')
