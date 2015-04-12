class FetchTorrentsFromRSS
  include Interactor::Organizer

  organize FetchRSSFeed,
           ParseRSS,
           ExtractTorrentsFromAbstractFeed
end
