Cataract.Deletion = DS.Model.extend
  torrent: DS.belongsTo('torrent', async: false)
  deletePayload: DS.attr('boolean')
