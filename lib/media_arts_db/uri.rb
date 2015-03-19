module MediaArtsDb

  BASE_URI = "http://mediaarts-db.jp"

  def self.search_comic_title_uri
    "#{BASE_URI}/mg/results"
  end

  def self.search_magazine_title_uri
    "#{BASE_URI}/mg/results/magazine_titles"
  end
end
