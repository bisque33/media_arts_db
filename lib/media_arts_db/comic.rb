module MediaArtsDb

  module ComicSearchOption
    TARGET_BOOK = 1
    TARGET_MAGAZINE_VOLUME = 2
    TARGET_MATERIAL = 3
    TARGET_ORIGINAL_PICTURE = 4
    TARGET_OTHER = 5

    START_YEAR = 'start_year' # 日付範囲指定（From年）
    START_MONTH = 'start_month' # 日付範囲指定（From月）
    END_YEAR = 'end_year' # 日付範囲指定（To年）
    END_MONTH = 'end_month' # 日付範囲指定（To月）

    ID = 1 # ID(ISBNなど)
    TITLE = 2 # 名称
    VOLUME = 3 # 巻・順序
    PERSON_NAME = 4 # 人名
    AUTHORITY_ID = 5 # 典拠ID
    PUBLISHER = 6 # 出版者
    LABEL = 7 # レーベル
    BOOK_SHAPE = 8 # 本の形状など
    TAG = 9 # タグ
    CATEGORY = 10 # 分類
    NOTE = 11 # 備考
    MAGAZINE_DISPLAY_VOLUME = 12 # [雑誌巻号]表示号数
    MAGAZINE_SUB_VOLUME = 13 # [雑誌巻号]補助号数
    MAGAZINE_VOLUME = 14 # [雑誌巻号]巻・号・通巻

    def self.enable_targets
      [TARGET_BOOK, TARGET_MAGAZINE_VOLUME, TARGET_MATERIAL, TARGET_ORIGINAL_PICTURE, TARGET_OTHER]
    end

    def self.enable_optins_for_time_range
      [START_YEAR, START_MONTH, END_YEAR, END_MONTH]
    end

    def self.enable_options
      [ID, TITLE, VOLUME, PERSON_NAME, AUTHORITY_ID, PUBLISHER, LABEL, BOOK_SHAPE, TAG, CATEGORY, NOTE]
    end

    def self.enable_options_for_magazine
      enable_options + [MAGAZINE_DISPLAY_VOLUME, MAGAZINE_SUB_VOLUME, MAGAZINE_VOLUME]
    end
  end

  class Comic < HttpBase

    include MediaArtsDb
    include MediaArtsDb::ComicSearchOption

    class << self

      def search_by_keyword(title: nil, magazine: nil, author: nil, per: 100, page: 1)
        uri = MediaArtsDb.comic_search_uri
        params = { per: per, page: page }
        if title
          params[:keyword_title] = title
          res_body = search_request(uri, params)
          parse_title_search_result(res_body)
        elsif magazine
          params[:keyword_magazine] = magazine
          res_body = search_request(uri, params)
          parse_magazine_search_result(res_body)
        elsif author
          params[:keyword_author] = author
          res_body = search_request(uri, params)
          parse_author_search_result(res_body)
        else
          return []
        end
      end

      def search_by_source(target: TARGET_BOOK, options: nil, per: 100, page: 1)
        return [] unless ComicSearchOption.enable_targets.include?(target)
        uri = MediaArtsDb.comic_search_uri
        params = { per: per, page: page }
        params['msf[target][]'] = target
        option_index = 1
        options.each do |key, value|
          case key
            when *ComicSearchOption.enable_optins_for_time_range
              params["msf[#{key}"] = value
            when *ComicSearchOption.enable_options
              next if option_index > 5
              params["msf[select#{option_index}]"] = key
              params["msf[text#{option_index}]"] = value
              option_index += 1
            when *ComicSearchOption.enable_options_for_magazine
              next unless target == TARGET_MAGAZINE_VOLUME
              next if option_index > 5
              params["msf[select#{option_index}]"] = key
              params["msf[text#{option_index}]"] = value
              option_index += 1
          end
        end

        res_body = search_request(uri, params)
        case target
          when TARGET_BOOK
            parse_book_search_result(res_body)
          when TARGET_MAGAZINE_VOLUME
            parse_magazine_volume_search_result(res_body)
          when TARGET_MATERIAL
            parse_material_search_result(res_body)
          when TARGET_ORIGINAL_PICTURE
            parse_original_picture_search_result(res_body)
          when TARGET_OTHER
            parse_other_search_result(res_body)
        end
      end


      def find_comic_works(id)
        uri = MediaArtsDb.comic_works_uri(id)
        res_body = http_get(uri)
        parse_comic_works_resutl(res_body)
      end

      def find_magazine_works(id)

      end

      def find_book_titles(id)

      end

      def find_book(id)

      end

      def find_magazine_titles(id)

      end

      def find_magazine(id)

      end

      def find_booklet(id)
        # 未実装
      end

      def find_authority(id)

      end

      private

      def parse_title_search_result(res_body)
        result = []
        doc = Nokogiri::HTML.parse(res_body)
        doc.css('div.resultTabA table > tbody > tr').each do |tr|
          row = {}
          link_url = tr.css('td:nth-child(1) a').attribute('href').value
          # リンクがcomic_worksとmagazine_worksの場合がある
          if link_url =~ /comic_works/
            row[:type] = 'comic_works'
            row[:comic_works_id] = clip_id(link_url)
          elsif link_url =~ /magazine_works/
            row[:type] = 'magazine_works'
            row[:magazine_works_id] = clip_id(link_url)
          end
          row[:title] = tr.css('td:nth-child(1)').text
          row[:auther] = tr.css('td:nth-child(2)').text
          row[:tags] = tr.css('td:nth-child(3)').text
          row[:total_comic_volume] = tr.css('td:nth-child(4)').text
          row[:total_magazine_volume] = tr.css('td:nth-child(5)').text
          row[:materials] = tr.css('td:nth-child(6)').text
          row[:original_picture] = tr.css('td:nth-child(7)').text
          row[:other] = tr.css('td:nth-child(8)').text

          result << row
        end
        result
      end

      def parse_magazine_search_result(res_body)
        result = []
        doc = Nokogiri::HTML.parse(res_body)
        doc.css('div.resultTabB table > tbody > tr').each do |tr|
          row = {}
          row[:type] = 'magazine_titles'
          row[:title] = tr.css('td:nth-child(1) > a').text
          link_url = tr.css('td:nth-child(1) > a').attribute('href').value
          row[:magazine_titles_id] = clip_id(link_url)
          row[:publisher] = tr.css('td:nth-child(2)').text
          row[:published_cycle] = tr.css('td:nth-child(3)').text
          row[:published_start_date] = tr.css('td:nth-child(4)').text
          row[:published_end_date] = tr.css('td:nth-child(5)').text
          row[:tags] = tr.css('td:nth-child(6)').text

          result << row
        end
        result
      end

      def parse_author_search_result(res_body)
        result = []
        doc = Nokogiri::HTML.parse(res_body)
        doc.css('div.resultTabC table > tbody > tr').each do |tr|
          row = {}
          row[:type] = 'none' # 何も値がないレコードがあるので、既定のtypeをnoneにしておく
          # リンクがauthoritiesとmagazine_worksの場合がある
          if tr.css('td:nth-child(1) > a').empty?
            row[:authority_name] = tr.css('td:nth-child(1)').text
          else
            row[:type] = 'authority'
            row[:authority_id] = clip_id(tr.css('td:nth-child(1) > a').attribute('href').value)
            row[:authority_name] = tr.css('td:nth-child(1) > a').text
          end
          row[:authority_name_kana] = tr.css('td:nth-child(2)').text
          # リンクの場合
          if tr.css('td:nth-child(3) > a').empty?
            row[:related_authority_name] = tr.css('td:nth-child(3)').text
          else
            row[:related_authority_id] = clip_id(tr.css('td:nth-child(3) > a').attribute('href').value)
            row[:related_authority_name] = tr.css('td:nth-child(3) > a').text
          end
          row[:book_title_quantity] = tr.css('td:nth-child(4)').text
          if tr.css('td:nth-child(5) > a').empty?
            row[:magazine_works_name] = tr.css('td:nth-child(5)').text
          else
            row[:type] = 'magazine_works'
            row[:magazine_works_id] = clip_id(tr.css('td:nth-child(5) > a').attribute('href').value)
            row[:magazine_works_name] = tr.css('td:nth-child(5) > a').text
          end

          result << row
        end
        result
      end

      def parse_book_search_result(res_body)
        result = []
        doc = Nokogiri::HTML.parse(res_body)
        doc.css('div.resultTabD_subA > div > table > tbody > tr').each do |tr|
          row = {}
          row[:type] = 'book'
          tmp_id = tr.css('td:nth-child(1)').text.split('<br>')
          if tmp_id.count == 1
            row[:isbn] = '-'  # ISBNは無くてもキーを作る
            # row[:separate_book_id] = tmp_id[0].gsub(/(\(|\))/, '') # 単行ID
          else
            row[:isbn] = tmp_id[0]  # ISBN
            # row[:separate_book_id] = tmp_id[1].gsub(/(\(|\))/, '') # 単行ID
          end
          if tr.css('td:nth-child(2) > a').empty?
            row[:book_title] = tr.css('td:nth-child(2)').text # 単行本名
          else
            row[:book_title] = tr.css('td:nth-child(2) > a').text # 単行本名
            row[:book_id] = clip_id(tr.css('td:nth-child(2) > a').attribute('href').value)
          end
          row[:label] = tr.css('td:nth-child(3)').text # 単行本レーベル
          row[:volume] = tr.css('td:nth-child(4)').text # 巻
          row[:author] = tr.css('td:nth-child(5)').text # 著者名
          row[:publisher] = tr.css('td:nth-child(6)').text # 出版者
          row[:published_date] = tr.css('td:nth-child(7)').text # 発行年月

          result << row
        end
        result
      end

      def parse_magazine_volume_search_result(res_body)
        result = []
        doc = Nokogiri::HTML.parse(res_body)
        doc.css('div.resultTabD_subB > div > table > tbody > tr').each do |tr|
          row = {}
          row[:type] = 'magazine'
          if tr.css('td:nth-child(2) > a').empty?
            row[:magazine_title] = tr.css('td:nth-child(2)').text # 雑誌名
          else
            row[:magazine_title] = tr.css('td:nth-child(2) > a').text # 雑誌名
            row[:magazine_id] = clip_id(tr.css('td:nth-child(2) > a').attribute('href').value)
          end
          row[:volume] = tr.css('td:nth-child(3)').text # 巻・合・通巻
          row[:display_volume] = tr.css('td:nth-child(4)').text # 表示号数
          row[:sub_volume] = tr.css('td:nth-child(5)').text # 補助号数
          row[:publisher] = tr.css('td:nth-child(6)').text # 出版者
          row[:published_date] = tr.css('td:nth-child(7)').text # 表示年月

          result << row
        end
        result
      end

      def parse_material_search_result(res_body)
        result = []
        doc = Nokogiri::HTML.parse(res_body)
        doc.css('div.resultTabD_subC > div > table > tbody > tr').each do |tr|
          row = {}
          row[:type] = 'material'
          if tr.css('td:nth-child(2) > a').empty?
            row[:material_title] = tr.css('td:nth-child(2)').text # 資料名
          else
            row[:material_title] = tr.css('td:nth-child(2) > a').text # 資料名
            row[:material_id] = clip_id(tr.css('td:nth-child(2) > a').attribute('href').value)
          end
          row[:category] = tr.css('td:nth-child(3)').text # 分類・カテゴリー
          row[:number] = tr.css('td:nth-child(4)').text # 順序
          row[:author] = tr.css('td:nth-child(5)').text # 著者名
          row[:related_material_title] = tr.css('td:nth-child(6)').text # 関連物
          row[:published_date] = tr.css('td:nth-child(7)').text # 時期

          result << row
        end
        result
      end

      def parse_original_picture_search_result(res_body)
        result = []
        doc = Nokogiri::HTML.parse(res_body)
        doc.css('div.resultTabD_subD > div > table > tbody > tr').each do |tr|
          row = {}
          row[:type] = 'original_picture'
          if tr.css('td:nth-child(2) > a').empty?
            row[:original_picture_title] = tr.css('td:nth-child(2)').text # 原画作品名
          else
            row[:original_picture_title] = tr.css('td:nth-child(2) > a').text # 原画作品名
            row[:original_picture_id] = clip_id(tr.css('td:nth-child(2) > a').attribute('href').value)
          end
          row[:recorded] = tr.css('td:nth-child(3)').text # 収録
          row[:number] = tr.css('td:nth-child(4)').text # 順序
          row[:quantity] = tr.css('td:nth-child(5)').text # 枚数
          row[:author] = tr.css('td:nth-child(6)').text # 著者名
          row[:published_date] = tr.css('td:nth-child(7)').text # 初出
          row[:writing_time] = tr.css('td:nth-child(8)').text # 執筆期間

          result << row
        end
        result
      end

      def parse_other_search_result(res_body)
        result = []
        doc = Nokogiri::HTML.parse(res_body)
        doc.css('div.resultTabD_subE > div > table > tbody > tr').each do |tr|
          row = {}
          row[:type] = 'other'
          if tr.css('td:nth-child(2) > a').empty?
            row[:other_title] = tr.css('td:nth-child(2)').text # 冊子名
          else
            row[:other_title] = tr.css('td:nth-child(2) > a').text # 冊子名
            row[:other_id] = clip_id(tr.css('td:nth-child(2) > a').attribute('href').value)
          end
          row[:series] = tr.css('td:nth-child(3)').text # シリーズ
          row[:volume] = tr.css('td:nth-child(4)').text # 巻
          row[:author] = tr.css('td:nth-child(6)').text # 著者名
          row[:publisher] = tr.css('td:nth-child(7)').text # 出版者・サークル名
          row[:published_date] = tr.css('td:nth-child(8)').text # 発行年月

          result << row
        end
        result
      end

      def parse_comic_works_resutl(res_body)
        result = {}
        doc = Nokogiri::HTML.parse(res_body)
        doc.css('body > article > div.main > section > table > tbody > tr').each do |tr|
          if tr.css('td > a').empty?
            case tr.css('th').text
              # HTML構造の誤りにより「マンガID」が取得できない
              # when 'マンガID' ; result[:comic_id] = tr.css('td').text
              when 'マンガ作品名' ; result[:title] = tr.css('td').text
              when 'マンガ作品名ヨミ' ; result[:title_kana] = tr.css('td').text
              when '別題・副題・原題' ; result[:sub_title] = tr.css('td').text
              when 'ローマ字表記' ; result[:title_alphabet] = tr.css('td').text
              when '著者（責任表示）' ; result[:author] = tr.css('td').text
              # when '著者典拠ID' ; result[:author_authority_id] = tr.css('td').text
              when '公表時期' ; result[:published_date] = tr.css('td').text
              when '出典（初出）' ; result[:source] = tr.css('td').text
              when 'マンガ作品紹介文・解説' ; result[:introduction] = tr.css('td').text
              when '分類' ; result[:category] = tr.css('td').text
              when 'タグ' ; result[:tags] = tr.css('td').text
              when 'レイティング' ; result[:rating] = tr.css('td').text
            end
          else
            case tr.css('th').text
              when '著者典拠ID'
                # 著者が複数の場合、著者典拠IDも複数になるが、それについてはまだ未実装
                # result[:author_authority_id] = tr.css('td > a').text
                result[:authority_id] = clip_id(tr.css('td > a').attribute('href').value)
            end
          end
        end

        result[:book_titles] = []
        doc.css('body > article > div.sub > section:nth-child(1) table').each do |table|
          table.css('tr').each do |tr|
            next if tr.css('td').empty?
            book_title = {}
            book_title[:title] = tr.css('td:nth-child(1) > a').text
            book_title[:book_titles_id] = clip_id(tr.css('td:nth-child(1) > a').attribute('href').value)
            book_title[:author] = tr.css('td:nth-child(2)').text
            book_title[:total_book_quantity] = tr.css('td:nth-child(3)').text
            result[:book_titles] << book_title
          end
        end

        result[:magazine_works] = []
        doc.css('body > article > div.sub > section:nth-child(2) table').each do |table|
          table.css('tr').each do |tr|
            next if tr.css('td').empty?
            magazine_works = {}
            magazine_works[:title] = tr.css('td:nth-child(1) > a').text
            magazine_works[:magazine_works_id] = clip_id(tr.css('td:nth-child(1) > a').attribute('href').value)
            magazine_works[:author] = tr.css('td:nth-child(2)').text
            magazine_works[:magazine_title] = tr.css('td:nth-child(3)').text
            magazine_works[:published_date] = tr.css('td:nth-child(4)').text
            result[:magazine_works] << magazine_works
          end
        end

        # 資料、マンガ原画、その他の冊子、関連マンガ作品は未実装

        # result[:anime_series] = []
        # doc.css('body > article > div.sub > section.anime table').each do |table|
        #   table.css('tr').each do |tr|
        #     next if tr.css('td').empty?
        #     # URIパラメータの調査が必要（未実装）
        #   end
        # end

        result
      end

      def search_request(uri, params)
        query = {
          query: {
            utf8: '✓',
            commit: '送信'
          }
        }
        params.each_key { |k| query[:query][k] = params[k] }
        http_get(uri, query)
      end

      def clip_id(uri)
        return nil unless uri.class == String
        # urlにqueryパラメータがある場合、?以降をを取り除く
        if uri.include?('?')
          index = uri =~ /\?/
          uri = uri[0..index - 1]
        end
        uri.slice(/[0-9]+$/)
      end
    end
  end
end