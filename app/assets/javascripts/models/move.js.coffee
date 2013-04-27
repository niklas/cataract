Cataract.Move = Emu.Model.extend
  torrent: Emu.field('Cataract.Torrent', partial: true)
  title: Emu.field('string')
  targetDisk: Emu.field('Cataract.Disk', partial: true)
  targetDirectory: Emu.field('Cataract.Directory', partial: true)
