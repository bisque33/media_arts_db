module MediaArtsDb

  # 未実装
  # Comicの各要素をクラス化して使う方式
  module Comic

    class SearchResult < HttpBase
      attr_accessor :type, :title, :comic_works_id, :magazine_works_id, :auther,
                    :tags, :total_comic_volume, :total_magazine_volume, :documents,
                    :original_picture, :other

      def get_comic_works(comic_works_id)
      end
    end

    class ComicWorks
      # 作品名、著者名、タグ、単行本全巻、雑誌掲載作品、資料、原画、その他
      def initialize(params)

      end
    end

    class MagazineWorks

    end

  end

end