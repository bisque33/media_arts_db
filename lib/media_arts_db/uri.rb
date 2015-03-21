module MediaArtsDb

  BASE_URI = "http://mediaarts-db.jp"

  def self.comic_search_title_uri
    "#{BASE_URI}/mg/results"
  end

  def self.comic_search_uri
    # "#{BASE_URI}/mg/results/others"
    "#{BASE_URI}/mg/results"
  end

  def self.comic_works_uri(id)
    "#{BASE_URI}/mg/comic_works/#{id}"
  end

  def self.comic_search_magazine_title_uri
    "#{BASE_URI}/mg/results/magazine_titles"
  end
end
