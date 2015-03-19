Cataract.initializer
  name: 'transfer-status'

  initialize: (container, application)->
    status = Ember.Object.create
      online: false # wait for first refreshTransfers
      offlineReason: 'loading...'

    application.register 'transfer-status:main', status, instantiate: false
    application.inject 'controller', 'transferStatus', 'transfer-status:main'
    application.inject 'component', 'transferStatus', 'transfer-status:main'
