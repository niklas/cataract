Cataract.Deletion = DS.Model.extend
  deletePayload: DS.attr('boolean')

Cataract.Deletion.reopenClass
  url: 'deletion' # Emu create param
