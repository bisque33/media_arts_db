module MediaArtsDb

  module ComicSearchOption
    ID = 1 # ID(ISBNなど)
    TITLE = 2 # 名称
    VOLUME = 3 # 巻・順序
    PERSON_NAME = 4 # 人名
    AUTHORITY_ID = 5 # 典拠ID
    PUBLISHER = 6 # 出版者
    LABEL = 7 # レーベル
    BOOK_SHAPE = 8 # 本の形状など
    TAG = 9 # タグ
    CLASSIFICATION = 10 # 分類
    NOTE = 11 # 備考
    MAGAZINE_DISPLAY_VOLUME = 12 # [雑誌巻号]表示号数
    MAGAZINE_SUB_VOLUME = 13 # [雑誌巻号]補助号数
    MAGAZINE_VOLUME = 14 # [雑誌巻号]巻・号・通巻
  end

  class Comic < HttpBase

    include MediaArtsDb
    include MediaArtsDb::ComicSearchOption

    class << self

      # ページングは未実装
      def search_title(keyword = nil, per = 100, offset = 0)
        result = []
        uri = MediaArtsDb.comic_search_title_uri
        params = { keyword_title: keyword, per: per, offset: offset }
        res_body = search_request(uri, params)
        return result unless res_body

        doc = Nokogiri::HTML.parse(res_body)
        doc.css('div.resultTabA table > tbody > tr').each do |tr|
          row = {}
          row[:title] = tr.css('td:nth-child(1)').text
          link_url = tr.css('td:nth-child(1) a').attribute('href').value
          # リンクがcomic_worksの場合と、magazine_worksの場合がある
          if link_url =~ /comic_works/
            row[:type] = 'comic'
            row[:comic_works_id] = link_url.scan(/[0-9]+$/).first
          elsif link_url =~ /magazine_works/
            row[:type] = 'magazine'
          end
          row[:auther] = tr.css('td:nth-child(2)').text
          row[:tags] = tr.css('td:nth-child(3)').text
          row[:total_comic_volume] = tr.css('td:nth-child(4)').text
          row[:total_magazine_volume] = tr.css('td:nth-child(5)').text
          row[:documents] = tr.css('td:nth-child(6)').text
          row[:original_picture] = tr.css('td:nth-child(7)').text
          row[:other] = tr.css('td:nth-child(8)').text

          result << row
        end

        result
      end

      def search_magazine(keyword = nil, per = 100, offset = 0)
        result = []
        uri = MediaArtsDb.comic_search_magazine_uri
        params = { keyword_magazine: keyword, per: per, offset: offset }
        res_body = search_request(uri, params)
        return result unless res_body


      end

      def search_authority(keyword = nil, per = 100, offset = 0)
        result = []
        uri = MediaArtsDb.comic_search_authority_uri
        params = { keyword_author: keyword, per: per, offset: offset }
        res_body = search_request(uri, params)
        return result unless res_body



      end

      def search_separate_book(start_date = nil, end_date = nil, detail = nil, per = 100, offset = 0)
        result = []
        uri = MediaArtsDb.comic_search_uri

        query_params = {
            'msf[target][]' => 1,
            # 'msf[target][]' => 2,
            # 'msf[target][]' => 3,
            # 'msf[target][]' => 4,
            # 'msf[target][]' => 5,
            # 'msf[start_year]' => '',
            # 'msf[start_month]' => '',
            # 'msf[end_year]' => '',
            # 'msf[end_month]' => '',
            # 'msf[code]' => '',
            # 'msf[select1]' => '',
            # 'msf[text1]' => '',
            # 'msf[select2]' => '',
            # 'msf[text2]' => '',
            # 'msf[select3]' => '',
            # 'msf[text3]' => '',
            # 'msf[select4]' => '',
            # 'msf[text4]' => '',
            # 'msf[select5]' => '',
            # 'msf[text5]' => '',
            per: per,
            offset: offset
        }
        if start_date && start_date.class.include?(Date)
          query_params['msf[start_year]'] = start_date.year
          query_params['msf[start_month]'] = start_date.month
        end
        if end_date && end_date.class.include?(Date)
          query_params['msf[end_year]'] = end_date.year
          query_params['msf[end_month]'] = end_date.month
        end

        # ID(ISBNなど)、名称、巻・順序、人名、典拠ID、出版者、レーベル、本の形状など、タグ、分類、備考
        detail.each_with_index do |(key, value), index|
          break if index >= 5
          query_params["msf[select#{index + 1}]"] = key
          query_params["msf[text#{index + 1}]"] = value
        end

        res_body = search_request(uri, query_params)
        return result unless res_body

        doc = Nokogiri::HTML.parse(res_body)
        doc.css('div.resultTabD_subA > div > table > tbody > tr').each do |tr|
          row = {}
          tmp_id = tr.css('td:nth-child(1)').text.split('<br>')
          if tmp_id.count == 1
            # row[:separate_book_id] = tmp_id[0].gsub(/(\(|\))/, '')
          else
            row[:isbn] = tmp_id[0]
            # row[:separate_book_id] = tmp_id[1].gsub(/(\(|\))/, '')
          end
          if tr.css('td:nth-child(2) > a').empty?
            row[:book_title] = tr.css('td:nth-child(2)').text
          else
            row[:book_title] = tr.css('td:nth-child(2) > a').text
            row[:book_id] = tr.css('td:nth-child(2) > a').attribute('href').value.scan(/[0-9]+$/).first
          end
          row[:label] = tr.css('td:nth-child(3)').text
          row[:volume] = tr.css('td:nth-child(4)').text
          row[:author] = tr.css('td:nth-child(5)').text
          row[:publisher] = tr.css('td:nth-child(6)').text
          row[:published_date] = tr.css('td:nth-child(7)').text

          result << row
        end

        result
      end


      def find_comic_works(id)
        result = {}

        uri = MediaArtsDb.comic_works_uri(id)
        res_body = http_get(uri)
        return result unless res_body

        doc = Nokogiri::HTML.parse(res_body)
        doc.css('body > article > div.main > section > table > tbody > tr').each do |tr|
          if tr.css('td > a').empty?
            case tr.css('th').text
              # HTML構造の誤りにより「マンガID」が取得できない
              when 'マンガID' ; result[:comic_id] = tr.css('td').text
              when 'マンガ作品名' ; result[:title] = tr.css('td').text
              when 'マンガ作品名ヨミ' ; result[:title_kana] = tr.css('td').text
              when '別題・副題・原題' ; result[:sub_title] = tr.css('td').text
              when 'ローマ字表記' ; result[:title_alphabet] = tr.css('td').text
              when '著者（責任表示）' ; result[:author] = tr.css('td').text
              when '公表時期' ; result[:published_date] = tr.css('td').text
              when '出典（初出）' ; result[:source] = tr.css('td').text
              when 'マンガ作品紹介文・解説' ; result[:introduction] = tr.css('td').text
              when '分類' ; result[:classification] = tr.css('td').text
              when 'タグ' ; result[:tags] = tr.css('td').text
              when 'レイティング' ; result[:rating] = tr.css('td').text
            end
          else
            case tr.css('th').text
              when '著者典拠ID'
                # 著者が複数の場合、著者典拠IDも複数になるが、それについてはまだ未実装
                result[:author_authority_id] = tr.css('td > a').text
                result[:authority_id] = tr.css('td > a').attribute('href').value.scan(/[0-9]+$/).first
            end
          end
        end

        result[:book_titles] = []
        doc.css('body > article > div.sub > section:nth-child(1) table').each do |table|
          table.css('tr').each do |tr|
            next if tr.css('td').empty?
            book_title = {}
            book_title[:title] = tr.css('td:nth-child(1) > a').text
            book_title[:book_titles_id] = tr.css('td:nth-child(1) > a').attribute('href').value.scan(/[0-9]+$/).first
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
            magazine_works[:magazine_works_id] = tr.css('td:nth-child(1) > a').attribute('href').value.scan(/[0-9]+$/).first
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
    end


  end

end