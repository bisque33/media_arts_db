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

      def initialize(option, per: 100, page: 1)
        @uri = MediaArtsDb.comic_search_uri
        @target = option.target
        @query = query_builder(option.build.merge({per: per, page: page}))
      end

      private

      def request
        HttpBase.get(@uri, @query)
      end

      def parse(response_body)
        case @target
          when 1
            Parse.parse_search_target_comic(response_body)
          when 2
            Parse.parse_search_target_magazine(response_body)
          when 3
            Parse.parse_search_target_material(response_body)
          when 4
            Parse.parse_search_target_original_picture(response_body)
          when 5
            Parse.parse_search_target_booklet(response_body)
        end
      end

      def option=(new_option)
        # YAGNI
      end

      def next_page
        # YAGNI
      end
    end

    class SearchOptionBuilder
      attr_reader :target

      def initialize
        @options = {}
      end
      def target_comic
        @target = 1
      end
      def target_magazine
        @target = 2
      end
      def target_material
        @target = 3
      end
      def target_original_picture
        @target = 4
      end
      def target_booklet
        @target = 5
      end
      def start_year=(start_year)
        @start_year = start_year
      end
      def start_month=(start_month)
        @start_month = start_month
      end
      def end_year=(end_year)
        @end_year = end_year
      end
      def end_month=(end_month)
        @end_month = end_month
      end
      def option_=(value)
        if value ; @options[1] = value ; else ; @options.delete(1) ; end
      end
      def option_title=(value)
        if value ; @options[2] = value ; else ; @options.delete(2) ; end
      end
      def option_volume_number=(value)
        if value ; @options[3] = value ; else ; @options.delete(3) ; end
      end
      def option_person_name=(value)
        if value ; @options[4] = value ; else ; @options.delete(4) ; end
      end
      def option_authority_id=(value)
        if value ; @options[5] = value ; else ; @options.delete(5) ; end
      end
      def option_publisher=(value)
        if value ; @options[6] = value ; else ; @options.delete(6) ; end
      end
      def option_label=(value)
        if value ; @options[7] = value ; else ; @options.delete(7) ; end
      end
      def option_book_format=(value)
        if value ; @options[8] = value ; else ; @options.delete(8) ; end
      end
      def option_tag=(value)
        if value ; @options[9] = value ; else ; @options.delete(9) ; end
      end
      def option_category=(value)
        if value ; @options[10] = value ; else ; @options.delete(10) ; end
      end
      def option_note=(value)
        if value ; @options[11] = value ; else ; @options.delete(11) ; end
      end
      def option_display_volume_number_with_magazine=(value)
        if value ; @options[12] = value ; else ; @options.delete(12) ; end
      end
      def option_display_volume_sub_number_with_magazine=(value)
        if value ; @options[13] = value ; else ; @options.delete(13) ; end
      end
      def option_volume_number_with_magazine=(value)
        if value ; @options[14] = value ; else ; @options.delete(14) ; end
      end

      def build
        result = {}
        raise 'Target has not been set.' unless @target
        result['msf[target][]'] = @target.to_s
        result[:start_year] = @start_year if @start_year
        result[:start_month] = @start_month if @start_month
        result[:end_year] = @end_year if @end_year
        result[:end_month] = @end_month if @end_month

        index = 1
        @options.each_pair do |key, value|
          break if index > 5
          result["msf[select#{index}]"] = key
          result["msf[text#{index}]"] = value
          index += 1
        end
        result
      end
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
      attr_accessor :id
      def initialize(id)
        @id = id
      end

      def execute
        class_name = @name.split(/_/).map(&:capitalize).join
        MediaArtsDb::Comic.const_get(class_name).new(@id, super(), true)
      end

      private

      def request
        HttpBase.get(uri)
      end

      def parse(response_body)
        Parse.send("parse_#{@name}", response_body)
      end

      def uri
        MediaArtsDb.send("comic_#{@name}_uri", @id)
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
        @query = query_builder({per: 1000}) # ページングはせずに、一度に大きく取得する
        super(id)
      end

      private

      # ComicTitleだけ結果にページングがあるので@queryを渡す必要がある
      def request
        HttpBase.get(uri, @query)
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