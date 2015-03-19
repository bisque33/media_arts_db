module MediaArtsDb
  module Comic
    class Search < HttpBase
      include MediaArtsDb
      # 作品名、雑誌名、著者名、単行本・雑誌・資料
      def search_comic_title(keyword = nil, per = 30)
        query = {
            "query" => {
                "keyword_title" => "カードキャプター",
                "per" => "30",
                "utf8" => "✓",
                "commit" => "送信"
            }
        }

        get(MediaArtsDb.search_comic_title_uri, query)
      end
    end

  end

end