describe 'Cataract.TransferView', ->
  view = null
  beforeEach ->
    view = Cataract.TransferView.create()
    Ember.run ->
      view.append()

  afterEach ->
    Ember.run ->
      view.remove()
    view = null

  it "is defined", ->
    expect(view).toBeDefined()

  it "shows eta", ->
    Ember.run -> view.set 'content', eta: 'future'
    expect( view.$('.eta').text() ).toEqual('future')

  it "does not show eta when not present", ->
    Ember.run -> view.set 'content', eta: null
    expect( view.$('.eta').length ).toEqual(0)

  it "shows progress as percent", ->
    Ember.run -> view.set 'content', progress: 23
    expect( view.$('.percent').text() ).toEqual('23%')

  it "sets style on bar", ->
    Ember.run -> view.set 'content', progressStyle: 'width: 42%'
    expect( view.$('.bar[style="width: 42%"]').length ).toEqual(1)

  it "shows down rate", ->
    Ember.run -> view.set 'content', downRate: '9001 KB/s'
    expect( view.$('.down').text() ).toEqual('9001 KB/s')

  it "shows up rate", ->
    Ember.run -> view.set 'content', upRate: '9001 KB/s'
    expect( view.$('.up').text() ).toEqual('9001 KB/s')

  it "is always green", ->
    Ember.run -> view.set 'content', {}
    expect( view.$('.progress.progress-success').length ).toEqual(1)

  it "is animated when downloading", ->
    Ember.run -> view.set 'content', downloading: true
    expect( view.$('.progress.active').length ).toEqual(1)

  it "stands still when stalled", ->
    Ember.run -> view.set 'content', downloading: false
    expect( view.$('.progress.active').length ).toEqual(0)

  it "is striped when not finished", ->
    Ember.run -> view.set 'content', finished: false
    expect( view.$('.progress.progress-striped').length ).toEqual(1)

  it "is not striped when finished", ->
    Ember.run -> view.set 'content', finished: true
    expect( view.$('.progress.progress-striped').length ).toEqual(0)

