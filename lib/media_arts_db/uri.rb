module MediaArtsDb

  BASE_URI = "http://mediaarts-db.jp"

  def self.comic_search_uri
    "#{BASE_URI}/mg/results"
  end

  def self.comic_comic_work_uri(id)
    "#{BASE_URI}/mg/comic_works/#{id}"
  end

  def self.comic_comic_title_uri(id)
    "#{BASE_URI}/mg/book_titles/#{id}"
  end

  def self.comic_comic_uri(id)
    "#{BASE_URI}/mg/books/#{id}"
  end

  def self.comic_magazine_work_uri(id)
    "#{BASE_URI}/mg/magazine_works/#{id}"
  end

  def self.comic_magazine_title_uri(id)
    "#{BASE_URI}/mg/magazine_titles/#{id}"
  end

  def self.comic_magazine_uri(id)
    "#{BASE_URI}/mg/magazines/#{id}"
  end

  def self.comic_author_uri(id)
    "#{BASE_URI}/mg/authorities/#{id}"
  end

  def self.comic_material_uri(id)
    "#{BASE_URI}/mg/materials/#{id}"
  end

  def self.comic_original_picture_uri(id)
    "#{BASE_URI}/mg/origins/#{id}"
  end

  def self.comic_booklet_uri(id)
    "#{BASE_URI}/mg/booklets/#{id}"
  end

end
