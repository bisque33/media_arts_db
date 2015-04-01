module MediaArtsDb
  module Comic
    def self.search

    end

    def self.search_work(keyword, per: 100, page: 1)
      SearchWork.new(keyword, per: per, page: page)
    end

    def self.search_magazine(keyword, per: 100, page: 1)
      SearchMagazine.new(keyword, per: per, page: page)
    end

    def self.search_author(keyword, per: 100, page: 1)
      SearchAuthor.new(keyword, per: per, page: page)
    end
  end
end