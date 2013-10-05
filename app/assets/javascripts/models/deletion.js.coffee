Cataract.Deletion = DS.Model.extend
  torrent: DS.belongsTo('torrent')
  deletePayload: DS.attr('boolean')
