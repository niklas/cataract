Cataract.Deletion = Emu.Model.extend
  deletePayload: Emu.field('boolean')

Cataract.Deletion.reopenClass
  url: 'deletion' # Emu create param
