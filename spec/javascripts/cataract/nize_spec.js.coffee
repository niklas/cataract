describe 'Cataract.Nize', ->
  view = null
  beforeEach ->
    view = Cataract.Nize.create()
    Ember.run ->
      view.append

  afterEach ->
    Ember.run ->
      view.remove()
    view = null

  it "is defined", ->
    expect(view).toBeDefined()

  it_shows = (value, word)->
    it "shows #{value} as #{word}", ->
      expect(word.length).toEqual(9)
      Ember.run ->
        view.set 'value', value
        expect( view.get('word') ).toEqual(word)

  it_shows(1                   ,'0________')
  it_shows(2                   ,'00_______')
  it_shows(3                   ,'000______')
  it_shows(8                   ,'00000000_')
  it_shows(9                   ,'000000000')
  it_shows(10                  ,'1________')
  it_shows(11                  ,'10_______')
  it_shows(23                  ,'11000____')
  it_shows(42                  ,'111100___')
  it_shows(666                 ,'222222111')
  it_shows(1981                ,'322222222')
  it_shows(1000000             ,'6________')
  it_shows(1000023             ,'611000___')
  it_shows(23000023            ,'776661100')
