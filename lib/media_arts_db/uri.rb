module MediaArtsDb

  BASE_URI = "http://mediaarts-db.jp"

  def self.comic_search_uri
    "#{BASE_URI}/mg/results"
  end

  def self.comic_comic_works_uri(id)
    "#{BASE_URI}/mg/comic_works/#{id}"
  end

  def self.comic_magazine_works_uri(id)
    "#{BASE_URI}/mg/magazine_works/#{id}"
  end

  def self.comic_book_titles_uri(id)
    "#{BASE_URI}/mg/book_titles/#{id}"
  end

  def self.comic_book_uri(id)
    "#{BASE_URI}/mg/books/#{id}"
  end

  def self.comic_magazine_titles_uri(id)
    "#{BASE_URI}/mg/magazine_titles/#{id}"
  end

  def self.comic_magazine_uri(id)
    "#{BASE_URI}/mg/magazines/#{id}"
  end

  def self.comic_booklet_uri(id)
    "#{BASE_URI}/mg/booklets/#{id}"
  end

  def self.comic_author_uri(id)
    "#{BASE_URI}/mg/authorities/#{id}"
  end

end
