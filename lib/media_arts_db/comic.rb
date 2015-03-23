module MediaArtsDb

  module ComicSearchOption
    TARGET_COMIC = 1
    TARGET_MAGAZINE_VOLUME = 2
    TARGET_MATERIAL = 3
    TARGET_ORIGINAL_PICTURE = 4
    TARGET_BOOKLET = 5

    START_YEAR = 'start_year' # 日付範囲指定（From年）
    START_MONTH = 'start_month' # 日付範囲指定（From月）
    END_YEAR = 'end_year' # 日付範囲指定（To年）
    END_MONTH = 'end_month' # 日付範囲指定（To月）

    ID = 1 # ID(ISBNなど)
    TITLE = 2 # 名称
    VOLUME = 3 # 巻・順序
    PERSON_NAME = 4 # 人名
    AUHTORITY_ID = 5 # 典拠ID
    PUBLISHER = 6 # 出版者
    LABEL = 7 # レーベル
    BOOK_FORMAT = 8 # 本の形状など
    TAG = 9 # タグ
    CATEGORY = 10 # 分類
    NOTE = 11 # 備考
    MAGAZINE_DISPLAY_VOLUME = 12 # [雑誌巻号]表示号数
    MAGAZINE_DISPLAY_SUB_VOLUME = 13 # [雑誌巻号]補助号数
    MAGAZINE_VOLUME = 14 # [雑誌巻号]巻・号・通巻

    def self.enable_targets
      [TARGET_COMIC, TARGET_MAGAZINE_VOLUME, TARGET_MATERIAL, TARGET_ORIGINAL_PICTURE, TARGET_BOOKLET]
    end

    def self.enable_optins_for_time_range
      [START_YEAR, START_MONTH, END_YEAR, END_MONTH]
    end

    def self.enable_options
      [ID, TITLE, VOLUME, PERSON_NAME, AUHTORITY_ID, PUBLISHER, LABEL, BOOK_FORMAT, TAG, CATEGORY, NOTE]
    end

    def self.enable_options_for_magazine
      enable_options + [MAGAZINE_DISPLAY_VOLUME, MAGAZINE_DISPLAY_SUB_VOLUME, MAGAZINE_VOLUME]
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

      def search_by_source(target: TARGET_COMIC, options: nil, per: 100, page: 1)
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
          when TARGET_COMIC
            parse_comic_search_result(res_body)
          when TARGET_MAGAZINE_VOLUME
            parse_magazine_volume_search_result(res_body)
          when TARGET_MATERIAL
            parse_material_search_result(res_body)
          when TARGET_ORIGINAL_PICTURE
            parse_original_picture_search_result(res_body)
          when TARGET_BOOKLET
            parse_booklet_search_result(res_body)
        end
      end


      def find_comic_works(id)
        uri = MediaArtsDb.comic_comic_works_uri(id)
        res_body = http_get(uri)
        parse_comic_works_result(res_body)
      end

      def find_comic_titles(id, per: 100, page: 1)
        uri = MediaArtsDb.comic_comic_titles_uri(id)
        params = { per: per, page: page }
        res_body = search_request(uri, params)
        parse_comic_titles_result(res_body)
      end

      def find_comic(id)
        uri = MediaArtsDb.comic_comic_uri(id)
        res_body = http_get(uri)
        parse_comic_result(res_body)
      end

      def find_magazine_works(id)
        uri = MediaArtsDb.comic_magazine_works_uri(id)
        res_body = http_get(uri)
        parse_magazine_works_result(res_body)
      end

      def find_magazine_titles(id)
        uri = MediaArtsDb.comic_magazine_titles_uri(id)
        res_body = http_get(uri)
        parse_magazine_titles_result(res_body)
      end

      def find_magazine(id)
        uri = MediaArtsDb.comic_magazine_uri(id)
        res_body = http_get(uri)
        parse_magazine_result(res_body)
      end

      def find_author(id)
        uri = MediaArtsDb.comic_author_uri(id)
        res_body = http_get(uri)
        parse_author_result(res_body)
      end

      def find_material(id)
        uri = MediaArtsDb.comic_material_uri(id)
        res_body = http_get(uri)
        parse_material_result(res_body)
      end

      def find_original_picture(id)
        uri = MediaArtsDb.comic_original_picture_uri(id)
        res_body = http_get(uri)
        parse_original_picture_result(res_body)
      end

      def find_booklet(id)
        uri = MediaArtsDb.comic_booklet_uri(id)
        res_body = http_get(uri)
        parse_booklet_result(res_body)
      end

      private

      def parse_title_search_result(res_body)
        result = []
        doc = Nokogiri::HTML.parse(res_body)
        doc.css('div.resultTabA table > tbody > tr').each do |tr|
          row = {}
          link_url = tr.css('td:nth-child(1) > a').attribute('href').value
          # リンクがcomic_worksとmagazine_worksの場合がある
          if link_url =~ /comic_works/
            row[:type] = 'comic_works'
            row[:comic_works_id] = clip_id(tr.css('td:nth-child(1) > a'))
          elsif link_url =~ /magazine_works/
            row[:type] = 'magazine_works'
            row[:magazine_works_id] = clip_id(tr.css('td:nth-child(1) > a'))
          end
          row[:title] = clip_text(tr.css('td:nth-child(1)'))  # 作品名
          row[:author] = tr.css('td:nth-child(2)').text # 著者名
          row[:tags] = tr.css('td:nth-child(3)').text # タグ
          row[:total_comic_volume] = tr.css('td:nth-child(4)').text # 単行本全巻
          row[:total_magazine_volume] = tr.css('td:nth-child(5)').text  # 雑誌掲載作品
          row[:materials] = tr.css('td:nth-child(6)').text  # 資料
          row[:original_picture] = tr.css('td:nth-child(7)').text # 原画
          row[:other] = tr.css('td:nth-child(8)').text  # その他

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
          row[:title] = clip_text(tr.css('td:nth-child(1)'))
          row[:magazine_titles_id] = clip_id(tr.css('td:nth-child(1) > a'))
          row[:publisher] = tr.css('td:nth-child(2)').text
          row[:published_interval] = tr.css('td:nth-child(3)').text
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
            row[:author_name] = tr.css('td:nth-child(1)').text
          else
            row[:type] = 'author'
            row[:author_id] = clip_id(tr.css('td:nth-child(1) > a'))
            row[:author_name] = clip_text(tr.css('td:nth-child(1)'))
          end
          row[:author_name_kana] = tr.css('td:nth-child(2)').text
          # リンクの場合
          if tr.css('td:nth-child(3) > a').empty?
            row[:related_author_name] = tr.css('td:nth-child(3)').text
          else
            row[:related_author_id] = clip_id(tr.css('td:nth-child(3) > a'))
            row[:related_author_name] = clip_text(tr.css('td:nth-child(3)'))
          end
          row[:comic_title_quantity] = tr.css('td:nth-child(4)').text
          if tr.css('td:nth-child(5) > a').empty?
            row[:magazine_works_name] = tr.css('td:nth-child(5)').text
          else
            row[:type] = 'magazine_works'
            row[:magazine_works_id] = clip_id(tr.css('td:nth-child(5) > a'))
            row[:magazine_works_name] = clip_text(tr.css('td:nth-child(5)'))
          end

          result << row
        end
        result
      end

      def parse_comic_search_result(res_body)
        result = []
        doc = Nokogiri::HTML.parse(res_body)
        doc.css('div.resultTabD_subA > div > table > tbody > tr').each do |tr|
          row = {}
          row[:type] = 'comic'
          tmp_id = tr.css('td:nth-child(1)').text.split('<br>')
          if tmp_id.count == 1
            row[:isbn] = '-'  # ISBNは無くてもキーを作る
          else
            row[:isbn] = tmp_id[0]  # ISBN
          end
          row[:comic_title] = clip_text(tr.css('td:nth-child(2)')) # 単行本名
          row[:comic_id] = clip_id(tr.css('td:nth-child(2) > a'))
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
          row[:magazine_title] = clip_text(tr.css('td:nth-child(2)')) # 雑誌名
          row[:magazine_id] = clip_id(tr.css('td:nth-child(2) > a'))
          row[:volume] = tr.css('td:nth-child(3)').text # 巻・合・通巻
          row[:display_volume] = tr.css('td:nth-child(4)').text # 表示号数
          row[:display_sub_volume] = tr.css('td:nth-child(5)').text # 補助号数
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
          row[:material_title] = clip_text(tr.css('td:nth-child(2)')) # 資料名
          row[:material_id] = clip_id(tr.css('td:nth-child(2) > a'))
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
          row[:original_picture_title] = clip_text(tr.css('td:nth-child(2)')) # 原画作品名
          row[:original_picture_id] = clip_id(tr.css('td:nth-child(2) > a'))
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

      def parse_booklet_search_result(res_body)
        result = []
        doc = Nokogiri::HTML.parse(res_body)
        doc.css('div.resultTabD_subE > div > table > tbody > tr').each do |tr|
          row = {}
          row[:type] = 'booklet'
          row[:booklet_title] = clip_text(tr.css('td:nth-child(2)')) # 冊子名
          row[:booklet_id] = clip_id(tr.css('td:nth-child(2) > a'))
          row[:series] = tr.css('td:nth-child(3)').text # シリーズ
          row[:volume] = tr.css('td:nth-child(4)').text # 巻
          row[:author] = tr.css('td:nth-child(6)').text # 著者名
          row[:publisher] = tr.css('td:nth-child(7)').text # 出版者・サークル名
          row[:published_date] = tr.css('td:nth-child(8)').text # 発行年月

          result << row
        end
        result
      end

      def parse_comic_works_result(res_body)
        result = {}
        doc = Nokogiri::HTML.parse(res_body)
        doc.css('body > article > div.main > section > table > tbody > tr').each do |tr|
          case tr.css('th:nth-child(1)').text
            # HTML構造の誤りにより「マンガID」が取得できない
            # when 'マンガID' ; result[:comic_id] = tr.css('td').text
            when 'マンガ作品名' ; result[:title] = tr.css('td').text
            when 'マンガ作品名ヨミ' ; result[:title_kana] = tr.css('td').text
            when '別題・副題・原題' ; result[:sub_title] = tr.css('td').text
            when 'ローマ字表記' ; result[:title_alphabet] = tr.css('td').text
            when '著者（責任表示）' ; result[:author] = tr.css('td').text
            # 著者が複数の場合、著者典拠IDも複数になるが、それについてはまだ未実装
            when '著者典拠ID' ; result[:author_id] = clip_id(tr.css('td > a'))
            when '公表時期' ; result[:published_date] = tr.css('td').text
            when '出典（初出）' ; result[:source] = tr.css('td').text
            when 'マンガ作品紹介文・解説' ; result[:introduction] = tr.css('td').text
            when '分類' ; result[:category] = tr.css('td').text
            when 'タグ' ; result[:tags] = tr.css('td').text
            when 'レイティング' ; result[:rating] = tr.css('td').text
          end
        end

        result[:comic_titles] = [] # 単行本全巻
        doc.css('body > article > div.sub > section:nth-child(1) table').each do |table|
          table.css('tr').each do |tr|
            next if tr.css('td').empty?
            comic_title = {}
            comic_title[:title] = clip_text(tr.css('td:nth-child(1)'))
            comic_title[:comic_titles_id] = clip_id(tr.css('td:nth-child(1) > a'))
            comic_title[:author] = tr.css('td:nth-child(2)').text
            comic_title[:total_comic_volume] = tr.css('td:nth-child(3)').text
            result[:comic_titles] << comic_title
          end
        end

        result[:magazine_works] = []  # 雑誌掲載作品
        doc.css('body > article > div.sub > section:nth-child(2) table').each do |table|
          table.css('tr').each do |tr|
            next if tr.css('td').empty?
            magazine_works = {}
            magazine_works[:title] = clip_text(tr.css('td:nth-child(1)'))
            magazine_works[:magazine_works_id] = clip_id(tr.css('td:nth-child(1) > a'))
            magazine_works[:author] = tr.css('td:nth-child(2)').text
            magazine_works[:magazine_title] = tr.css('td:nth-child(3)').text
            magazine_works[:published_date] = tr.css('td:nth-child(4)').text
            result[:magazine_works] << magazine_works
          end
        end

        # 資料、マンガ原画、その他の冊子、関連マンガ作品はサンプルが見つからないので未実装

        result
      end

      def parse_comic_titles_result(res_body)
        result = {}
        doc = Nokogiri::HTML.parse(res_body)
        doc.css('body > article > div.main > section > table > tbody > tr').each do |tr|
          case tr.css('th:nth-child(1)').text
            when '作品ID' ; result[:comic_works_id] = clip_id(tr.css('td > a'))
            when '単行本全巻名' ; result[:title] = tr.css('td').text
            when '単行本全巻名 ヨミ' ; result[:title_kana] = tr.css('td').text
            when '単行本全巻名 追記' ; result[:title_append] = tr.css('td').text
            when '単行本全巻名 追記 ヨミ' ; result[:title_append_kana] = tr.css('td').text
            when '単行本全巻名 別版表示' ; result[:title_other] = tr.css('td').text
            when '単行本全巻数' ; result[:total_comic_volume] = tr.css('td').text
            when '責任表示' ; result[:responsible] = tr.css('td').text
            when '著者典拠ID' ; result[:author_id] = clip_id(tr.css('td > a'))
            when '作者・著者' ; result[:author] = tr.css('td').text
            when '作者・著者 ヨミ' ; result[:author_kana] = tr.css('td').text
            when '原作・原案' ; result[:origina] = tr.css('td').text
            when '原作・原案 ヨミ' ; result[:origina_kana] = tr.css('td').text
            when '協力者' ; result[:collaborator] = tr.css('td').text
            when '協力者 ヨミ' ; result[:collaborator_kana] = tr.css('td').text
            when '標目' ; result[:headings] = tr.css('td').text
            when '単行本レーベル' ; result[:label] = tr.css('td').text
            when '単行本レーベル ヨミ' ; result[:label_kana] = tr.css('td').text
            when 'シリーズ' ; result[:series] = tr.css('td').text
            when 'シリーズ ヨミ' ; result[:series_kana] = tr.css('td').text
            when '出版者名' ; result[:publisher] = tr.css('td').text
            when '出版地' ; result[:published_area] = tr.css('td').text
            when '縦の長さ×横の長さ' ; result[:size] = tr.css('td').text
            when 'ISBNなどのセットコード' ; result[:isbn] = tr.css('td').text
            when '言語区分' ; result[:langage] = tr.css('td').text
            when '分類' ; result[:category] = tr.css('td').text
            when 'レイティング' ; result[:rating] = tr.css('td').text
            when '単行本全巻紹介文' ; result[:introduction] = tr.css('td').text
            when '単行本全巻タグ' ; result[:tags] = tr.css('td').text
            when '単行本全巻備考' ; result[:note] = tr.css('td').text
          end
        end

        result[:comics] = [] # 単行本
        doc.css('body > article > div.sub > section:nth-child(1) table tbody tr').each do |tr|
          next if tr.css('td').empty?
          comic_title = {}
          comic_title[:title] = clip_text(tr.css('td:nth-child(1)'))
          comic_title[:comic_id] = clip_id(tr.css('td:nth-child(1) > a'))
          comic_title[:comic_title_append] = tr.css('td:nth-child(2)').text
          comic_title[:volume] = tr.css('td:nth-child(3)').text
          result[:comics] << comic_title
        end

        result
      end

      def parse_comic_result(res_body)
        result = {
            next_id: '',
            prev_id: '',
            basic_information: nil,
            author_information: nil,
            publisher_information: nil,
            other_information: nil
        }
        doc = Nokogiri::HTML.parse(res_body)
        return result if doc.css('body > article > div.main > section:nth-child(1) > table').empty?

        # 前巻/次巻
        result[:prev_id] = clip_id(doc.css('body > article > header > ul > li.bookSkip > ul > li.prv > a'))
        result[:next_id] = clip_id(doc.css('body > article > header > ul > li.bookSkip > ul > li.nxt > a'))

        # 基本情報
        tbody = doc.css('body > article > div.main > section:nth-child(1) > table > tbody')
        basic_information = {}
        basic_information[:comic_titles_is] = clip_id(tbody.css('tr:nth-child(1) > td:nth-child(4) > a'))
        basic_information[:comic_title] = tbody.css('tr:nth-child(2) > td').text
        basic_information[:comic_title_kana] = tbody.css('tr:nth-child(3) > td').text
        basic_information[:comic_title_append] = tbody.css('tr:nth-child(4) > td').text
        basic_information[:comic_title_append_kana] = tbody.css('tr:nth-child(5) > td').text
        basic_information[:volume] = tbody.css('tr:nth-child(6) > td:nth-child(2)').text
        basic_information[:volume_sort_number] = tbody.css('tr:nth-child(6) > td:nth-child(4)').text
        basic_information[:volume_other_number] = tbody.css('tr:nth-child(7) > td').text
        basic_information[:introduction] = tbody.css('tr:nth-child(8) > td').text
        result[:basic_information] = basic_information
        # 著者表示
        tbody = doc.css('body > article > div.main > section:nth-child(2) > table > tbody')
        author_information = {}
        author_information[:responsible] = tbody.css('tr:nth-child(1) > td').text
        author_information[:author_id] = clip_id(tbody.css('tr:nth-child(2) > td > a:nth-child(1)'))
        author_information[:headings] = tbody.css('tr:nth-child(3) > td').text
        author_information[:auhtor] = tbody.css('tr:nth-child(4) > td:nth-child(2)').text
        author_information[:auhtor_kana] = tbody.css('tr:nth-child(4) > td:nth-child(4)').text
        author_information[:original_title] = tbody.css('tr:nth-child(5) > td:nth-child(2)').text
        author_information[:original_title_kana] = tbody.css('tr:nth-child(5) > td:nth-child(4)').text
        author_information[:collaborator] = tbody.css('tr:nth-child(6) > td:nth-child(2)').text
        author_information[:collaborator_kana] = tbody.css('tr:nth-child(6) > td:nth-child(4)').text
        result[:author_information] = author_information
        # 出版者・レーベル
        tbody = doc.css('body > article > div.main > section:nth-child(3) > table > tbody')
        publisher_information = {}
        publisher_information[:publisher] = tbody.css('tr:nth-child(1) > td').text
        publisher_information[:label] = tbody.css('tr:nth-child(3) > td').text
        publisher_information[:label_kana] = tbody.css('tr:nth-child(4) > td').text
        publisher_information[:label_number] = tbody.css('tr:nth-child(5) > td:nth-child(2)').text
        publisher_information[:series] = tbody.css('tr:nth-child(6) > td:nth-child(2)').text
        publisher_information[:series_kana] = tbody.css('tr:nth-child(6) > td:nth-child(4)').text
        result[:publisher_information] = publisher_information
        # その他
        tbody = doc.css('body > article > div.main > section:nth-child(4) > table > tbody')
        other_information = {}
        other_information[:published_date] = tbody.css('tr:nth-child(1) > td:nth-child(2)').text
        other_information[:first_price] = tbody.css('tr:nth-child(1) > td:nth-child(4)').text
        other_information[:isbn] = tbody.css('tr:nth-child(2) > td').text
        other_information[:japan_book_number] = tbody.css('tr:nth-child(3) > td').text
        other_information[:total_page] = tbody.css('tr:nth-child(4) > td:nth-child(2)').text
        other_information[:size] = tbody.css('tr:nth-child(4) > td:nth-child(4)').text
        other_information[:langage] = tbody.css('tr:nth-child(5) > td:nth-child(2)').text
        other_information[:published_area] = tbody.css('tr:nth-child(5) > td:nth-child(4)').text
        other_information[:rating] = tbody.css('tr:nth-child(6) > td').text
        other_information[:category] = tbody.css('tr:nth-child(7) > td').text
        other_information[:tags] = tbody.css('tr:nth-child(8) > td').text
        other_information[:note] = tbody.css('tr:nth-child(9) > td').text
        result[:other_information] = other_information

        result
      end

      def parse_magazine_works_result(res_body)
        result = {}
        doc = Nokogiri::HTML.parse(res_body)
        doc.css('body > article > div.main > section > table > tbody > tr').each do |tr|
          case tr.css('th:nth-child(1)').text
            when '雑誌作品名' ; result[:title] = tr.css('td').text
            when '雑誌作品名 ヨミ' ; result[:title_kana] = tr.css('td').text
            when '作者・著者' ; result[:author] = tr.css('td').text
            when '作者・著者 ヨミ' ; result[:author_kana] = tr.css('td').text
            when '原作・原案' ; result[:original] = tr.css('td').text
            when '原作・原案 ヨミ' ; result[:original_kana] = tr.css('td').text
            when '協力者' ; result[:collaborator] = tr.css('td').text
            when '協力者 ヨミ' ; result[:collaborator_kana] = tr.css('td').text
            when 'タグ' ; result[:tags] = tr.css('td').text
            when '備考' ; result[:note] = tr.css('td').text
          end
        end

        result[:magazines] = [] # 雑誌巻号
        doc.css('body > article > div.sub > section > div.moreBlock table.infoTbl2 tbody tr').each do |tr|
          next if tr.css('td').empty?
          magazine = {}
          magazine[:title] = clip_text(tr.css('td:nth-child(1)'))
          magazine[:magazine_id] = clip_id(tr.css('td:nth-child(1) > a'))
          magazine[:published_date] = tr.css('td:nth-child(2)').text
          magazine[:display_volume] = tr.css('td:nth-child(3)').text
          magazine[:display_sub_volume] = tr.css('td:nth-child(4)').text
          result[:magazines] << magazine
        end

        result
      end

      def parse_magazine_titles_result(res_body)
        result = {}
        doc = Nokogiri::HTML.parse(res_body)
        doc.css('body > article > div.main > section > table > tbody > tr').each do |tr|
          case tr.css('th:nth-child(1)').text
            when '雑誌名' ; result[:title] = tr.css('td').text
            when '雑誌名 ヨミ' ; result[:title_kana] = tr.css('td').text
            when '出版者名' ; result[:publisher] = tr.css('td').text
            when '出版地' ; result[:published_area] = tr.css('td').text
            when '発行頻度' ; result[:published_interval] = tr.css('td').text
            when '変遷' ; result[:history] = tr.css('td').text
            when '紹介文' ; result[:introduction] = tr.css('td').text
            when '創刊年月日' ; result[:published_start_date] = tr.css('td').text
            when '終刊年月日' ; result[:published_end_date] = tr.css('td').text
            when '終刊表示号数' ; result[:display_last_volume] = tr.css('td').text
            when '終刊巻'
              result[:last_volume] = tr.css('td:nth-child(2)').text
              result[:volume] = tr.css('td:nth-child(4)').text
              result[:volume2] = tr.css('td:nth-child(6)').text
            when 'ISSN' ; result[:issn] = tr.css('td').text
            when '全国書誌番号' ; result[:japan_book_number] = tr.css('td').text
            when '大阪タイトルコード' ; result[:osaka_title_code] = tr.css('td').text
            when '言語区分' ; result[:langage] = tr.css('td').text
            when 'タグ' ; result[:tags] = tr.css('td').text
            when '備考' ; result[:note] = tr.css('td').text
          end
        end

        result[:magazines] = [] # 雑誌巻号
        doc.css('body > article > div.sub > section > div.moreBlock table.infoTbl2 tbody tr').each do |tr|
          next if tr.css('td').empty?
          magazine = {}
          magazine[:title] = clip_text(tr.css('td:nth-child(1)'))
          magazine[:magazine_id] = clip_id(tr.css('td:nth-child(1) > a'))
          magazine[:published_date] = tr.css('td:nth-child(2)').text
          magazine[:display_volume] = tr.css('td:nth-child(3)').text
          magazine[:display_sub_volume] = tr.css('td:nth-child(4)').text
          result[:magazines] << magazine
        end

        result
      end

      def parse_magazine_result(res_body)
        result = {
            next_id: '',
            prev_id: '',
            basic_information: nil,
            other_information: nil,
            contents: []
        }
        doc = Nokogiri::HTML.parse(res_body)
        return result if doc.css('body > article > div.main > section:nth-child(1) > table').empty?

        # Next/Prev
        result[:prev_id] = clip_id(doc.css('body > article > header > ul > li.bookSkip > ul > li.prv > a'))
        result[:next_id] = clip_id(doc.css('body > article > header > ul > li.bookSkip > ul > li.nxt > a'))

        # 基本情報
        basic_information = {}
        doc.css('body > article > div.main > section:nth-child(1) > table > tbody > tr').each do |tr|
          case tr.css('th:nth-child(1)').text
            when 'サブタイトル' ; basic_information[:sub_title] = tr.css('td').text
            when 'サブタイトルヨミ' ; basic_information[:sub_title_kana] = tr.css('td').text
            when '表示年月日' ; basic_information[:display_date] = tr.css('td').text
            when '表示月日(合併)' ; basic_information[:display_date_merger] = tr.css('td').text
            when '発行年月日' ; basic_information[:published_date] = tr.css('td').text
            when '発行月日(合併)' ; basic_information[:published_date_merger] = tr.css('td').text
            when '発売年月日' ; basic_information[:release_date] = tr.css('td').text
            when '表示号数' ; basic_information[:display_volume] = tr.css('td').text
            when '表示合併号数' ; basic_information[:display_merger_volume] = tr.css('td').text
            when '補助号数' ; basic_information[:display_sub_volume] = tr.css('td').text
            when '巻'
              basic_information[:volume] = tr.css('td:nth-child(2)').text
              basic_information[:volume2] = tr.css('td:nth-child(4)').text  # 適当な名前がわからない
              basic_information[:volume3] = tr.css('td:nth-child(6)').text  # 適当な名前がわからない
          end
        end
        result[:basic_information] = basic_information

        # 出版者、ページ数、価格
        other_information = {}
        doc.css('body > article > div.main > section:nth-child(2) > table > tbody > tr').each do |tr|
          case tr.css('th:nth-child(1)').text
            when '出版者名' ; other_information[:publisher] = tr.css('td').text
            when '発行人' ; other_information[:publisher2] = tr.css('td').text
            when '編集人' ; other_information[:publisher3] = tr.css('td').text
            when 'ページ数' ; other_information[:total_page] = tr.css('td').text
            when '製本' ; other_information[:binding] = tr.css('td').text
            when '分類' ; other_information[:category] = tr.css('td').text
            when 'レイティング' ; other_information[:rating] = tr.css('td').text
            when '縦の長さx横の長さ' ; other_information[:size] = tr.css('td').text
            when '価格' ; other_information[:price] = tr.css('td').text
            when '雑誌コード' ; other_information[:magazine_code] = tr.css('td').text
            when 'タグ' ; other_information[:tags] = tr.css('td').text
            when '備考' ; other_information[:note] = tr.css('td').text
          end
        end
        result[:other_information] = other_information

        # 雑誌巻号
        doc.css('body > article > div.sub > section:nth-child(2) > table > tbody > tr').each do |tr|
          next if tr.css('td').empty?
          contents = {}
          contents[:category] = tr.css('td:nth-child(1)').text
          contents[:title] = clip_text(tr.css('td:nth-child(2)'))
          contents[:magazine_works_id] = clip_id(tr.css('td:nth-child(2) > a'))
          contents[:author] = tr.css('td:nth-child(3)').text
          contents[:sub_title] = tr.css('td:nth-child(4)').text
          contents[:start_page] = tr.css('td:nth-child(5)').text
          contents[:total_page] = tr.css('td:nth-child(6)').text
          contents[:note] = tr.css('td:nth-child(7)').text
          contents[:format] = tr.css('td:nth-child(8)').text
          result[:contents] << contents
        end

        result
      end

      def parse_author_result(res_body)
        result = {}
        doc = Nokogiri::HTML.parse(res_body)
        doc.css('body > article > div.main > section > table > tbody > tr').each do |tr|
          case tr.css('th:nth-child(1)').text
            # HTML構造の誤りにより「マンガID」が取得できない
            # when 'マンガID' ; result[:comic_id] = tr.css('td').text
            when '標目' ; result[:headings] = tr.css('td').text
            when '名称' ; result[:name] = tr.css('td').text
            when 'ヨミ' ; result[:name_kana] = tr.css('td').text
            when 'ローマ字' ; result[:name_alphabet] = tr.css('td').text
            when 'をも見よ参照' ; result[:reference] = tr.css('td').text
            # 著者が複数の場合、著者典拠IDも複数になるが、それについてはまだ未実装
            when '別名（表記ミス・ユレ、本名、新字旧字など）' ; result[:other_name] = clip_id(tr.css('td > a'))
            when '生年月日(結成年月日)' ; result[:birthday] = tr.css('td').text
            when '没年月日' ; result[:death_date] = tr.css('td').text
          end
        end

        result[:comic_works] = [] # 単行本化された作品 ※マンガ作品
        doc.css('body > article > div.sub > section:nth-child(1) table').each do |table|
          table.css('tr').each do |tr|
            next if tr.css('td').empty?
            comic_works = {}
            comic_works[:title] = clip_text(tr.css('td:nth-child(1)'))
            comic_works[:comic_works_id] = clip_id(tr.css('td:nth-child(1) > a'))
            comic_works[:author] = tr.css('td:nth-child(2)').text
            result[:comic_works] << comic_works
          end
        end

        result[:comic_titles] = []  # 単行本全巻
        doc.css('body > article > div.sub > section:nth-child(2) table').each do |table|
          table.css('tr').each do |tr|
            next if tr.css('td').empty?
            comic_titles = {}
            comic_titles[:title] = clip_text(tr.css('td:nth-child(1)'))
            comic_titles[:comic_titles_id] = clip_id(tr.css('td:nth-child(1) > a'))
            comic_titles[:author] = tr.css('td:nth-child(2)').text
            comic_titles[:total_comic_volume] = tr.css('td:nth-child(3)').text
            result[:comic_titles] << comic_titles
          end
        end

        # 資料、マンガ原画、その他の冊子、関連マンガ作品はサンプルが見つからないので未実装

        result
      end

      def parse_material_result(res_body)
        # 未実装
        {}
      end

      def parse_original_picture_result(res_body)
        # 未実装
        {}
      end

      def parse_booklet_result(res_body)
        result = {
            basic_information: nil,
            author_information: nil,
            publisher_information: nil,
            other_information: nil
        }
        doc = Nokogiri::HTML.parse(res_body)

        basic_information = {}
        doc.css('body > article > div.main > section:nth-child(1) > table > tbody > tr').each do |tr|
          case tr.css('th:nth-child(1)').text
            when 'その他の冊子ID' ; basic_information[:comic_works_id] = clip_id(tr.css('td:nth-child(4) > a'))
            when '分類' ; basic_information[:category] = tr.css('td').text
            when '冊子名'
              basic_information[:title] = tr.css('td').text.gsub(/\n/, '').strip
              # basic_information[:title_kana] = tr.next.css('td').text # このやり方では取れない
            when '冊子名追記'
              basic_information[:title_append] = tr.css('td').text
              # basic_information[:title_append_kana] = tr.next.css('td').text # このやり方では取れない
            when '巻'
              basic_information[:volume] = tr.css('td:nth-child(2)').text
              basic_information[:volume_sort_number] = tr.css('td:nth-child(4)').text
            when '冊子名別版表示' ; basic_information[:title_other] = tr.css('td').text
            when '紹介文' ; basic_information[:introduction] = tr.css('td').text
          end
        end
        result[:basic_information] = basic_information

        author_information = {}
        doc.css('body > article > div.main > section:nth-child(2) > table > tbody > tr').each do |tr|
          case tr.css('th:nth-child(1)').text
            when '責任表示' ; author_information[:authority] = tr.css('td').text
            when '著者典拠ID'
              author_information[:author_id] = clip_id(tr.css('td a').text)
            when '作者・著者'
              author_information[:author] = tr.css('td:nth-child(2)').text
              author_information[:author_kana] = tr.css('td:nth-child(4)').text
            when '原作・原案'
              author_information[:original] = tr.css('td:nth-child(2)').text
              author_information[:original_kana] = tr.css('td:nth-child(4)').text
            when '協力者'
              author_information[:collaborator] = tr.css('td:nth-child(2)').text
              author_information[:collaborator_kana] = tr.css('td:nth-child(4)').text
            when '標目' ; author_information[:headings] = tr.css('td').text
          end
        end
        result[:author_information] = author_information

        publisher_information = {}
        doc.css('body > article > div.main > section:nth-child(3) > table > tbody > tr').each do |tr|
          case tr.css('th:nth-child(1)').text
            when '出版者名（サークル名）' ; publisher_information[:publisher] = tr.css('td').text
            when 'シリーズ' ; publisher_information[:series] = tr.css('td').text
            when 'カナ' ; publisher_information[:series_kana] = tr.css('td').text
            when 'シリーズ番号' ; publisher_information[:series_number] = tr.css('td').text
            when '頒布イベント' ; publisher_information[:published_event] = tr.css('td').text
          end
        end
        result[:publisher_information] = publisher_information

        other_information = {}
        doc.css('body > article > div.main > section:nth-child(4) > table > tbody > tr').each do |tr|
          case tr.css('th:nth-child(1)').text
            when '初版発行年月日'
              other_information[:published_data] = tr.css('td:nth-child(2)').text
              other_information[:price] = tr.css('td:nth-child(4)').text
            when '発行日備考' ; other_information[:published_data_note] = tr.css('td').text
            when '全国書誌番号' ; other_information[:japan_book_number] = tr.css('td').text
            when '製本・造本形態' ; other_information[:format] = tr.css('td').text
            when 'ページ数'
              other_information[:total_page] = tr.css('td:nth-child(2)').text
              other_information[:size] = tr.css('td:nth-child(4)').text
            when '発行地'
              other_information[:published_area] = tr.css('td:nth-child(2)').text
              other_information[:publisher] = tr.css('td:nth-child(4)').text
            when '言語区分' ; other_information[:langage] = tr.css('td').text
            when 'レイティング' ; other_information[:rating] = tr.css('td').text
            when 'タグ' ; other_information[:tags] = tr.css('td').text
            when '備考' ; other_information[:note] = tr.css('td').text
          end
        end
        result[:other_information] = other_information

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

      def clip_text(node)
        # return '' unless node.class == Nokogiri::XML::NodeSet
        begin
          node.css('a').empty? ? node.text : node.css('a').text
        rescue
          ''
        end
      end

      def clip_id(node)
        # return '' unless node.class == Nokogiri::XML::NodeSet && node.attribute('href')
        begin
          uri = node.attribute('href').value
          # urlにqueryパラメータがある場合、?以降をを取り除く
          if uri.include?('?')
            index = uri =~ /\?/
            uri = uri[0..index - 1]
          end
          uri.slice(/[0-9]+$/)
        rescue
          ''
        end
      end
    end
  end
end