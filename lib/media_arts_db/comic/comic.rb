module MediaArtsDb

  module Comic

    # class ComicSearchResult
    #
    # end
    #
    # class ComicWorks
    #   # 作品名、著者名、タグ、単行本全巻、雑誌掲載作品、資料、原画、その他
    #   attr_accessor :
    #   def initialize(params)
    #
    #   end
    # end

    class Comic < HttpBase

      include MediaArtsDb

      # 作品名、雑誌名、著者名、単行本・雑誌・資料
      def find_title(keyword = nil, per = 30, offset = 0)
        query = {
            "query" => {
                "keyword_title" => keyword,
                "per" => per,
                "utf8" => "✓",
                "commit" => "送信"
            }
        }

        res_body = http_get(MediaArtsDb.search_comic_title_uri, query)
        doc = Nokogiri::HTML.parse(res_body)

        results = []
        doc.css('body > article > div > div.resultTabA > section > table > tbody > tr').each do |tr|
          result = {}
          result[:title] = tr.css('td:nth-child(1)').text
          link_url = tr.css('td:nth-child(1) a').attribute("href").value
          # リンクがcomic_worksの場合と、magazine_worksの場合がある
          if link_url =~ /comic_works/
            result[:type] = "comic"
            result[:comic_works_id] = link_url.scan(/[0-9]+$/).first
          elsif link_url =~ /magazine_works/
            result[:type] = "magazine"
          end

          result[:auther] = tr.css('td:nth-child(2)').text
          result[:tags] = tr.css('td:nth-child(3)').text.split('　／　')
          result[:totla_comic_volume] = tr.css('td:nth-child(4)').text
          result[:total_magazine_volume] = tr.css('td:nth-child(5)').text
          result[:documents] = tr.css('td:nth-child(6)').text
          result[:original_picture] = tr.css('td:nth-child(7)').text
          result[:other] = tr.css('td:nth-child(8)').text

          results << result

        end

        return results

      end
    end

  end

end