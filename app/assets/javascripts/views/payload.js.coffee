Cataract.PayloadView = Ember.View.extend
  templateName: 'payload'
  classNames: ['payload']
  isShowingFiles: false

  toggleFiles: (event) ->
    @set 'isShowingFiles', !@get('isShowingFiles')
    false

