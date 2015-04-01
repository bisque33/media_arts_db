module MediaArtsDb
  module Comic
    class RetrieveTemplate

      def execute
        response_body = request
        response_body ? parse(response_body) : false
      end

      private

      def request
        # オーバーライドしてください
        false
      end

      def parse(response_body)
        # オーバーライドしてください
        false
      end

      def query_builder(params)
        { query: params.merge({ utf8: '✓', commit: '送信' }) }
      end
    end

    class Search < RetrieveTemplate

      # def initialize(keyword, per: 100, page: 1)
      #   @uri = MediaArtsDb.comic_search_uri
      #   @query = query_builder({keyword_title: keyword, per: per, page: page})
      # end
      #
      # private
      #
      # def request
      #   HttpBase.get(@uri, @query)
      # end
      #
      # def parse(response_body)
      #   Parse.parse_search_xxx(response_body)
      # end
      #
      # def keyword=(new_keyword)
      #   # YAGNI
      # end
      #
      # def next_page
      #   # YAGNI
      # end
    end

    class SearchWork < RetrieveTemplate

      def initialize(keyword, per: 100, page: 1)
        @uri = MediaArtsDb.comic_search_uri
        @query = query_builder({keyword_title: keyword, per: per, page: page})
      end

      private

      def request
        HttpBase.get(@uri, @query)
      end

      def parse(response_body)
        Parse.parse_search_title(response_body)
      end

      def keyword=(new_keyword)
        # YAGNI
      end

      def next_page
        # YAGNI
      end
    end

    class SearchMagazine < RetrieveTemplate

      def initialize(keyword, per: 100, page: 1)
        @uri = MediaArtsDb.comic_search_uri
        @query = query_builder({keyword_magazine: keyword, per: per, page: page})
      end

      private

      def request
        HttpBase.get(@uri, @query)
      end

      def parse(response_body)
        Parse.parse_search_magazine(response_body)
      end

      def keyword=(new_keyword)
        # YAGNI
      end

      def next_page
        # YAGNI
      end
    end

    class SearchAuthor < RetrieveTemplate

      def initialize(keyword, per: 100, page: 1)
        @uri = MediaArtsDb.comic_search_uri
        @query = query_builder({keyword_author: keyword, per: per, page: page})
      end

      private

      def request
        HttpBase.get(@uri, @query)
      end

      def parse(response_body)
        Parse.parse_search_author(response_body)
      end

      def keyword=(new_keyword)
        # YAGNI
      end

      def next_page
        # YAGNI
      end
    end

    class FindTemplate < RetrieveTemplate
      def initialize(id)
        self.id = id
      end

      private

      def request
        HttpBase.get(@uri)
      end

      def parse(response_body)
        Parse.send("parse_#{@name}", response_body)
      end

      def id=(new_id)
        @uri = MediaArtsDb.send("comic_#{@name}_uri", new_id)
      end
    end

    class FindComicWork < FindTemplate
      def initialize(id)
        @name = 'comic_work'
        super(id)
      end
    end

    class FindComicTitle < FindTemplate
      def initialize(id)
        @name = 'comic_title'
        @query = query_builder({per: 1000}) # ページングは実装せずに、一度に取得する
        super(id)
      end

      private

      def request
        HttpBase.get(@uri, @query)
      end
    end

    class FindComic < FindTemplate
      def initialize(id)
        @name = 'comic'
        super(id)
      end
    end

    class FindMagazineWork < FindTemplate
      def initialize(id)
        @name = 'magazine_work'
        super(id)
      end
    end

    class FindMagazineTitle < FindTemplate
      def initialize(id)
        @name = 'magazine_title'
        super(id)
      end
    end

    class FindMagazine < FindTemplate
      def initialize(id)
        @name = 'magazine'
        super(id)
      end
    end

    class FindAuthor < FindTemplate
      def initialize(id)
        @name = 'author'
        super(id)
      end
    end

    class FindMaterial < FindTemplate
      def initialize(id)
        @name = 'material'
        super(id)
      end
    end

    class FindOriginalPicture < FindTemplate
      def initialize(id)
        @name = 'original_picture'
        super(id)
      end
    end

    class FindBooklet < FindTemplate
      def initialize(id)
        @name = 'booklet'
        super(id)
      end
    end
  end
end