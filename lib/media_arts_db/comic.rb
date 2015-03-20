module MediaArtsDb

  class Comic < HttpBase

    include MediaArtsDb

    # 作品名、雑誌名、著者名、単行本・雑誌・資料

    class << self

      def title_search(keyword = nil, per = 100, offset = 0)

        result = []

        query = {
            query: {
            keyword_title: keyword,
            per: per,
            utf8: '✓',
            commit: '送信'
        }
        }

        res_body = http_get(MediaArtsDb.search_comic_title_uri, query)
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
          row[:tags] = tr.css('td:nth-child(3)').text.split('　／　')
          row[:total_comic_volume] = tr.css('td:nth-child(4)').text
          row[:total_magazine_volume] = tr.css('td:nth-child(5)').text
          row[:documents] = tr.css('td:nth-child(6)').text
          row[:original_picture] = tr.css('td:nth-child(7)').text
          row[:other] = tr.css('td:nth-child(8)').text

          result << row

        end

        result
      end


      def find_comic_work(id)
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
              when 'マンガ作品名' ; result[:comic_title] = tr.css('td').text
              when 'マンガ作品名ヨミ' ; result[:comic_title_kana] = tr.css('td').text
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
            book_title[:book_title] = tr.css('td:nth-child(1) > a').text
            book_title[:book_title_id] = tr.css('td:nth-child(1) > a').attribute('href').value.scan(/[0-9]+$/).first
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
            magazine_works[:comic_title] = tr.css('td:nth-child(1) > a').text
            magazine_works[:magazine_works_id] = tr.css('td:nth-child(1) > a').attribute('href').value.scan(/[0-9]+$/).first
            magazine_works[:author] = tr.css('td:nth-child(2)').text
            magazine_works[:magazine_title] = tr.css('td:nth-child(3)').text
            magazine_works[:published_date] = tr.css('td:nth-child(4)').text
            result[:magazine_works] << magazine_works
          end
        end

        # 資料、マンガ原画、その他の冊子、関連マンガ作品は未実装

        result[:anime_series] = []
        doc.css('body > article > div.sub > section.anime table').each do |table|
          table.css('tr').each do |tr|
            next if tr.css('td').empty?
            # URIパラメータの調査が必要（未実装）
          end
        end

        result
      end

      def find_magazine_work(id)

      end

      def find_book_title(id)

      end

      def find_book(id)

      end

      def find_magazine_title(id)

      end

      def find_magazine(id)

      end

      def find_booklet(id)
        # 未実装
      end

      def find_authority(id)

      end


    end


  end

end