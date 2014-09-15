# http://stackoverflow.com/questions/13342250/how-to-manually-set-an-object-state-to-clean-saved-using-ember-data
DS.Model.reopen
  sideUpdateAttributes: (attrs={})->
    @setProperties attrs
    # changing to loaded.updated.inFlight, which has "didCommit"
    @send 'willCommit'
    # clear array of changed (dirty) model attributes
    @set '_attributes', {}
    # changing to loaded.saved (hooks didCommit event in "inFlight" state)
    @send 'didCommit'
