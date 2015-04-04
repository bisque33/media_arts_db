require "nokogiri"

module MediaArtsDb
  module Comic
    class Parse
      class << self
        def parse_search_title(response_body)
          contents = []
          doc = Nokogiri::HTML.parse(response_body)
          doc.css('div.resultTabA table > tbody > tr').each do |tr|
            content = {}
            content[:title] = clip_text(tr, 1)  # 作品名
            content[:author] = clip_text(tr, 2) # 著者名
            content[:tags] = clip_text(tr, 3) # タグ
            content[:comic_title_quantity] = clip_text(tr, 4) # 単行本全巻
            content[:magazine_work_quantity] = clip_text(tr, 5)  # 雑誌掲載作品
            content[:material_quantity] = clip_text(tr, 6)  # 資料 クラス化非対応
            content[:original_picture_quantity] = clip_text(tr, 7) # 原画 クラス化非対応
            content[:booklet_quantity] = clip_text(tr, 8)  # その他 クラス化非対応

            # リンクがcomic_worksとmagazine_worksの場合がある
            # TODO: link_urlが正しいか確認する
            case clip_uri(tr, 1)
              when /comic_works/
                contents << ComicWork.new(clip_id(tr, 1), content)
              when /magazine_works/
                contents << MagazineWork.new(clip_id(tr, 1), content)
            end
          end
          contents
        end

        def parse_search_magazine(response_body)
          contents = []
          doc = Nokogiri::HTML.parse(response_body)
          doc.css('div.resultTabB table > tbody > tr').each do |tr|
            content = {}
            content[:title] = clip_text(tr, 1)
            content[:publisher] = clip_text(tr, 2)
            content[:published_interval] = clip_text(tr, 3)
            content[:published_start_date] = clip_text(tr, 4)
            content[:published_end_date] = clip_text(tr, 5)
            content[:tags] = clip_text(tr, 6)

            contents << MagazineTitle.new(clip_id(tr, 1), content)
          end
          contents
        end

        def parse_search_author(response_body)
          contents = []
          doc = Nokogiri::HTML.parse(response_body)
          doc.css('div.resultTabC table > tbody > tr').each do |tr|
            # NOTE:
            # 検索結果に著者名の行と雑誌掲載作品名の行があるが、
            # 検索したいのは著者名なので雑誌掲載作品名の行は無視する
            next unless has_id?(tr, 1)

            content = {}
            content[:name] = clip_text(tr, 1)
            content[:name_kana] = clip_text(tr, 2)
            content[:related_authors] = clip_authors(tr, 3)
            content[:comic_work_quantity] = clip_text(tr, 4)
            # content[:magazine_works_name] = clip_text(tr, 5)

            contents << Author.new(clip_id(tr, 1), content)
          end
          contents
        end

        def parse_search_target_comic(response_body)
          contents = []
          doc = Nokogiri::HTML.parse(response_body)
          doc.css('div.resultTabD_subA > div > table > tbody > tr').each do |tr|
            content = {}
            content[:isbn10] = clip_isbn10(tr, 1) # ISBN10
            content[:isbn13] = clip_isbn13(tr, 1) # ISBN13
            content[:title] = clip_text(tr, 2) # 単行本名
            content[:label] = clip_text(tr, 3) # 単行本レーベル
            content[:volume] = clip_text(tr, 4) # 巻
            content[:author] = clip_text(tr, 5) # 著者名
            content[:publisher] = clip_text(tr, 6) # 出版者
            content[:published_date] = clip_text(tr, 7) # 発行年月

            contents << Comic.new(clip_id(tr, 2), content)
          end
          contents
        end

        def parse_search_target_magazine(response_body)
          contents = []
          doc = Nokogiri::HTML.parse(response_body)
          doc.css('div.resultTabD_subB > div > table > tbody > tr').each do |tr|
            content = {}
            content[:title] = clip_text(tr, 2) # 雑誌名
            content[:volume] = clip_text(tr, 3) # 巻・合・通巻
            content[:display_volume] = clip_text(tr, 4) # 表示号数
            content[:display_sub_volume] = clip_text(tr, 5) # 補助号数
            content[:publisher] = clip_text(tr, 6) # 出版者
            content[:published_date] = clip_text(tr, 7) # 表示年月

            contents << Magazine.new(clip_id(tr, 2), content)
          end
          contents
        end

        def parse_search_target_material(response_body)
          contents = []
          doc = Nokogiri::HTML.parse(response_body)
          doc.css('div.resultTabD_subC > div > table > tbody > tr').each do |tr|
            content = {}
            content[:title] = clip_text(tr, 2) # 資料名
            content[:category] = clip_text(tr, 3) # 分類・カテゴリー
            content[:number] = clip_text(tr, 4) # 順序
            content[:author] = clip_text(tr, 5) # 著者名
            content[:related_material_title] = clip_text(tr, 6) # 関連物
            content[:published_date] = clip_text(tr, 7) # 時期

            contents << Material.new(clip_id(tr, 2), content)
          end
          contents
        end

        def parse_search_target_original_picture(response_body)
          contents = []
          doc = Nokogiri::HTML.parse(response_body)
          doc.css('div.resultTabD_subD > div > table > tbody > tr').each do |tr|
            content = {}
            content[:title] = clip_text(tr, 2) # 原画作品名
            content[:recorded] = clip_text(tr, 3) # 収録
            content[:number] = clip_text(tr, 4) # 順序
            content[:quantity] = clip_text(tr, 5) # 枚数
            content[:author] = clip_text(tr, 6) # 著者名
            content[:published_date] = clip_text(tr, 7) # 初出
            content[:writing_time] = clip_text(tr, 8) # 執筆期間

            contents << OriginalPicture.new(clip_id(tr, 2), content)
          end
          contents
        end

        def parse_search_target_booklet(response_body)
          contents = []
          doc = Nokogiri::HTML.parse(response_body)
          doc.css('div.resultTabD_subE > div > table > tbody > tr').each do |tr|
            content = {}
            content[:title] = clip_text(tr, 2) # 冊子名
            content[:series] = clip_text(tr, 3) # シリーズ
            content[:volume] = clip_text(tr, 4) # 巻
            content[:author] = clip_text(tr, 5) # 著者名
            content[:publisher] = clip_text(tr, 6) # 出版者・サークル名
            content[:published_date] = clip_text(tr, 7) # 発行年月

            contents << Booklet.new(clip_id(tr, 2), content)
          end
          contents
        end

        def parse_comic_work(response_body)
          content = {}
          doc = Nokogiri::HTML.parse(response_body)
          tbody = doc.css('body > article > div.main > section > table > tbody')
          # NOTE: HTML構造の誤りにより要素番号をずらす必要がある。
          offset = 1
          content[:title] = clip_text(tbody, 2, 2 + offset) # マンガ作品名
          content[:title_kana] = clip_text(tbody, 2, 3 + offset) # マンガ作品名ヨミ
          content[:sub_title] = clip_text(tbody, 2, 4 + offset) # 別題・副題・原題
          content[:title_alphabet] = clip_text(tbody, 2, 5 + offset) # ローマ字表記
          # content[:author] = clip_text(tbody, 2, 6 + offset) # 著者（責任表示） # author.nameを参照するためコメントアウト
          content[:authors] = clip_authors(tbody, 2, 7 + offset) # 著者典拠ID
          content[:published_date] = clip_text(tbody, 2, 8 + offset) # 公表時期
          content[:source] = clip_text(tbody, 2, 9 + offset) # 出典（初出）
          content[:introduction] = clip_text(tbody, 2, 10 + offset) # マンガ作品紹介文・解説
          content[:category] = clip_text(tbody, 2, 11 + offset) # 分類
          content[:tags] = clip_text(tbody, 2, 12 + offset) # タグ
          content[:rating] = clip_text(tbody, 2, 13 + offset) # レイティング

          content[:comic_title_quantity] = doc.css('body > article > div.sub > section:nth-child(1) > h3 > span').text
          content[:comic_titles] = [] # 単行本全巻
          doc.css('body > article > div.sub > section:nth-child(1) table').each do |table|
            table.css('tr').each do |tr|
              next if tr.css('td').empty?
              comic_title_content = {}
              comic_title_content[:title] = clip_text(tr, 1)
              comic_title_content[:author] = clip_text(tr, 2)
              comic_title_content[:total_comic_volume] = clip_text(tr, 3)
              content[:comic_titles] << ComicTitle.new(clip_id(tr, 1), comic_title_content)
            end
          end

          content[:magazine_work_quantity] = doc.css('body > article > div.sub > section:nth-child(2) > h3 > span').text
          content[:magazine_works] = []  # 雑誌掲載作品
          doc.css('body > article > div.sub > section:nth-child(2) table').each do |table|
            table.css('tr').each do |tr|
              next if tr.css('td').empty?
              magazine_work_content = {}
              magazine_work_content[:title] = clip_text(tr, 1)
              magazine_work_content[:author] = clip_text(tr, 2)
              magazine_work_content[:magazine_title] = clip_text(tr, 3)
              magazine_work_content[:published_date] = clip_text(tr, 4)
              content[:magazine_works] << MagazineWork.new(clip_id(tr, 1), magazine_work_content)
            end
          end

          # 資料、マンガ原画、その他の冊子、関連マンガ作品はサンプルが見つからないので未実装

          content
        end

        def parse_comic_title(response_body)
          result = {}
          doc = Nokogiri::HTML.parse(response_body)
          tbody = doc.css('body > article > div.main > section > table > tbody')
          # NOTE: HTML構造の誤りにより要素番号をずらす必要がある。
          offset = 1
          result[:comic_work] = ComicWork.new(clip_id(tbody, 2, 2 + offset))
          result[:title] = clip_text(tbody, 2, 3 + offset)  # 単行本全巻名
          result[:title_kana] = clip_text(tbody, 2, 4 + offset) # 単行本全巻名 ヨミ
          result[:title_append] = clip_text(tbody, 2, 5 + offset) # 単行本全巻名 追記
          result[:title_append_kana] = clip_text(tbody, 2, 6 + offset)  # 単行本全巻名 追記 ヨミ
          result[:title_other] = clip_text(tbody, 2, 7 + offset)  # 単行本全巻名 別版表示
          # result[:total_comic_volume] = clip_text(tbody, 2, 8 + offset) # 単行本全巻数 comic_quantityと同値なのでコメントアウト
          result[:responsible] = clip_text(tbody, 2, 9 + offset)  # 責任表示
          result[:author] = clip_text(tbody, 2, 10 + offset) # 作者・著者
          result[:author_kana] = clip_text(tbody, 2, 11 + offset)  # 作者・著者 ヨミ
          result[:origina] = clip_text(tbody, 2, 12 + offset)  # 原作・原案
          result[:origina_kana] = clip_text(tbody, 2, 13 + offset) # 原作・原案 ヨミ
          result[:collaborator] = clip_text(tbody, 2, 14 + offset) # 協力者
          result[:collaborator_kana] = clip_text(tbody, 2, 15 + offset)  # 協力者 ヨミ
          result[:headings] = clip_text(tbody, 2, 16 + offset) # 標目
          result[:authors] = clip_authors(tbody, 2, 17 + offset)  # 著者典拠ID
          result[:label] = clip_text(tbody, 2, 18 + offset)  # 単行本レーベル
          result[:label_kana] = clip_text(tbody, 2, 19 + offset) # 単行本レーベル ヨミ
          result[:series] = clip_text(tbody, 2, 21 + offset) # シリーズ
          result[:series_kana] = clip_text(tbody, 2, 22 + offset)  # シリーズ ヨミ
          result[:publisher] = clip_text(tbody, 2, 23 + offset)  # 出版者名
          result[:published_area] = clip_text(tbody, 2, 25 + offset) # 出版地
          result[:size] = clip_text(tbody, 2, 26 + offset) # 縦の長さ×横の長さ
          result[:isbn] = clip_text(tbody, 2, 27 + offset) # ISBNなどのセットコード
          result[:langage] = clip_text(tbody, 2, 28 + offset)  # 言語区分
          result[:category] = clip_text(tbody, 2, 29 + offset) # 分類
          result[:rating] = clip_text(tbody, 2, 30 + offset) # レイティング
          result[:introduction] = clip_text(tbody, 2, 31 + offset) # 単行本全巻紹介文
          result[:tags] = clip_text(tbody, 2, 32 + offset) # 単行本全巻タグ
          result[:note] = clip_text(tbody, 2, 33 + offset) # 単行本全巻備考

          result[:comic_quantity] = doc.css('body > article > div.sub > section > nav > h3 > span').text
          result[:comics] = [] # 単行本
          doc.css('body > article > div.sub > section:nth-child(1) > table > tbody > tr').each do |tr|
            next if tr.css('td').empty?
            content = {}
            content[:title] = clip_text(tr, 1)
            content[:title_append] = clip_text(tr, 2)
            content[:volume] = clip_text(tr, 3)
            result[:comics] << Comic.new(clip_id(tr, 1), content)
          end

          result
        end

        def parse_comic(response_body)
          result = {}
          doc = Nokogiri::HTML.parse(response_body)
          return result if doc.css('body > article > div.main > section:nth-child(1) > table').empty?

          # 前巻/次巻
          prev_id = clip_id(doc.css('body > article > header > ul > li.bookSkip > ul > li.prv > a'))
          result[:prev_comic] = prev_id ? Comic.new(prev_id) : nil
          next_id = clip_id(doc.css('body > article > header > ul > li.bookSkip > ul > li.nxt > a'))
          result[:next_comic] = next_id ? Comic.new(next_id) : nil

          # 基本情報
          tbody = doc.css('body > article > div.main > section:nth-child(1) > table > tbody')
          result[:comic_title] = ComicTitle.new(clip_id(tbody, 4, 1))
          result[:title] = clip_text(tbody, 2, 2)
          result[:title_kana] = clip_text(tbody, 2, 3)
          result[:title_append] = clip_text(tbody, 2, 4)
          result[:title_append_kana] = clip_text(tbody, 2, 5)
          result[:volume] = clip_text(tbody, 2, 6)
          result[:volume_sort_number] = clip_text(tbody, 4, 6)
          result[:volume_other_number] = clip_text(tbody, 2, 7)
          result[:introduction] = clip_text(tbody, 2, 8)

          # 著者表示
          tbody = doc.css('body > article > div.main > section:nth-child(2) > table > tbody')
          result[:responsible] = clip_text(tbody, 2, 1)
          result[:authors] = clip_authors(tbody, 2, 2)
          result[:headings] = clip_text(tbody, 2, 3)
          result[:auhtor] = clip_text(tbody, 2, 4)
          result[:auhtor_kana] = clip_text(tbody, 4, 4)
          result[:original_title] = clip_text(tbody, 2, 5)
          result[:original_title_kana] = clip_text(tbody, 4, 5)
          result[:collaborator] = clip_text(tbody, 2, 5)
          result[:collaborator_kana] = clip_text(tbody, 4, 6)

          # 出版者・レーベル
          tbody = doc.css('body > article > div.main > section:nth-child(3) > table > tbody')
          result[:publisher] = clip_text(tbody, 2, 1)
          result[:label] = clip_text(tbody, 2, 3)
          result[:label_kana] = clip_text(tbody, 2, 4)
          result[:label_number] = clip_text(tbody, 2, 5)
          result[:series] = clip_text(tbody, 2, 6)
          result[:series_kana] = clip_text(tbody, 4, 6)

          # その他
          tbody = doc.css('body > article > div.main > section:nth-child(4) > table > tbody')
          result[:published_date] = clip_text(tbody, 2, 1)
          result[:first_price] = clip_text(tbody, 4, 1)
          result[:isbn10] = clip_isbn10(tbody, 2, 2)
          result[:isbn13] = clip_isbn13(tbody, 2, 2)
          result[:japan_book_number] = clip_text(tbody, 2, 3)
          result[:total_page] = clip_text(tbody, 2, 4)
          result[:size] = clip_text(tbody, 4, 4)
          result[:langage] = clip_text(tbody, 2, 5)
          result[:published_area] = clip_text(tbody, 4, 5)
          result[:rating] = clip_text(tbody, 2, 6)
          result[:category] = clip_text(tbody, 2, 7)
          result[:tags] = clip_text(tbody, 2, 8)
          result[:note] = clip_text(tbody, 2, 9)

          result
        end

        def parse_magazine_work(response_body)
          result = {}
          doc = Nokogiri::HTML.parse(response_body)
          tbody = doc.css('body > article > div.main > section > table > tbody')
          # NOTE: HTML構造の誤りにより要素番号をずらす必要がある。
          offset = 1
          result[:title] = clip_text(tbody, 2, 2 + offset)  # 雑誌作品名
          result[:title_kana] = clip_text(tbody, 2, 3 + offset) # 雑誌作品名 ヨミ
          result[:author] = clip_text(tbody, 2, 4 + offset) # 作者・著者
          result[:author_kana] = clip_text(tbody, 2, 5 + offset)  # 作者・著者 ヨミ
          result[:original] = clip_text(tbody, 2, 6 + offset) # 原作・原案
          result[:original_kana] = clip_text(tbody, 2, 7 + offset)  # 原作・原案 ヨミ
          result[:collaborator] = clip_text(tbody, 2, 8 + offset) # 協力者
          result[:collaborator_kana] = clip_text(tbody, 2, 9 + offset)  # 協力者 ヨミ
          result[:tags] = clip_text(tbody, 2, 10 + offset) # タグ
          result[:note] = clip_text(tbody, 2, 11 + offset) # 備考

          result[:magazines] = [] # 雑誌巻号
          doc.css('body > article > div.sub > section > div.moreBlock table.infoTbl2 tbody tr').each do |tr|
            next if tr.css('td').empty?
            content = {}
            content[:title] = clip_text(tr, 1)
            content[:published_date] = clip_text(tr, 2)
            content[:display_volume] = clip_text(tr, 3)
            content[:display_sub_volume] = clip_text(tr, 4)
            result[:magazines] << Magazine.new(clip_id(tr, 1), content)
          end

          result
        end

        def parse_magazine_title(response_body)
          result = {}
          doc = Nokogiri::HTML.parse(response_body)
          tbody = doc.css('body > article > div.main > section > table > tbody')
          # NOTE: 「雑誌略号ID」部分のHTML構造の誤りにより要素番号をずらす必要がある。
          offset = 1
          result[:title] = clip_text(tbody, 2, 2 + offset)  # 雑誌名
          result[:title_kana] = clip_text(tbody, 2, 3 + offset) # 雑誌名 ヨミ
          result[:publisher] = clip_text(tbody, 2, 4 + offset)  # 出版者名
          result[:published_area] = clip_text(tbody, 2, 6 + offset) # 出版地
          result[:published_interval] = clip_text(tbody, 2, 7 + offset) # 発行頻度
          result[:history] = clip_text(tbody, 2, 8 + offset)  # 変遷
          result[:introduction] = clip_text(tbody, 2, 9 + offset) # 紹介文
          result[:published_start_date] = clip_text(tbody, 2, 10 + offset) # 創刊年月日
          result[:published_end_date] = clip_text(tbody, 2, 11 + offset) # 終刊年月日
          result[:display_last_volume] = clip_text(tbody, 2, 12 + offset)  # 終刊表示号数
          result[:last_volume] = clip_text(tbody, 2, 13 + offset) # 終刊号
          result[:volume] = clip_text(tbody, 4, 13 + offset)  # 号
          result[:volume2] = clip_text(tbody, 6, 13 + offset) # 巻号
          # NOTE: 「ISSN」部分のHTML構造の誤りにより要素番号をずらす必要がある。
          # result[:issn] = clip_text(tbody, 2, 14 + offset) # ISSN
          offset = 2
          result[:japan_book_number] = clip_text(tbody, 2, 15 + offset)  # 全国書誌番号
          result[:osaka_title_code] = clip_text(tbody, 2, 16 + offset) # 大阪タイトルコード
          result[:langage] = clip_text(tbody, 2, 17 + offset)  # 言語区分
          result[:tags] = clip_text(tbody, 2, 18 + offset) # タグ
          result[:note] = clip_text(tbody, 2, 19 + offset) # 備考

          result[:magazines] = [] # 雑誌巻号
          doc.css('body > article > div.sub > section > div.moreBlock table.infoTbl2 tbody tr').each do |tr|
            next if tr.css('td').empty?
            content = {}
            content[:title] = clip_text(tr, 1)
            content[:published_date] = clip_text(tr, 2)
            content[:display_volume] = clip_text(tr, 3)
            content[:display_sub_volume] = clip_text(tr, 4)
            result[:magazines] << Magazine.new(clip_id(tr, 1), content)
          end

          result
        end

        def parse_magazine(response_body)
          result = {}
          doc = Nokogiri::HTML.parse(response_body)
          return result if doc.css('body > article > div.main > section:nth-child(1) > table').empty?

          # Next/Prev
          prev_id = clip_id(doc.css('body > article > header > ul > li.bookSkip > ul > li.prv > a'))
          result[:prev_magazine] = prev_id ? Magazine.new(prev_id) : nil
          next_id = clip_id(doc.css('body > article > header > ul > li.bookSkip > ul > li.nxt > a'))
          result[:next_magazine] = next_id ? Magazine.new(next_id) : nil

          # 基本情報
          tbody = doc.css('body > article > div.main > section:nth-child(1) > table > tbody')
          # NOTE: 「雑誌略号ID」部分のHTML構造の誤りにより要素番号をずらす必要がある。
          offset = 2
          result[:sub_title] = clip_text(tbody, 2, 3 + offset) # サブタイトル
          result[:sub_title_kana] = clip_text(tbody, 2, 4 + offset)  # サブタイトルヨミ
          result[:display_date] = clip_text(tbody, 2, 5 + offset)  # 表示年月日
          result[:display_date_merger] = clip_text(tbody, 2, 6 + offset) # 表示月日(合併 + offset)
          result[:published_date] = clip_text(tbody, 2, 7 + offset)  # 発行年月日
          result[:published_date_merger] = clip_text(tbody, 2, 8 + offset) # 発行月日(合併 + offset)
          result[:release_date] = clip_text(tbody, 2, 9 + offset)  # 発売年月日
          result[:display_volume] = clip_text(tbody, 2, 10 + offset)  # 表示号数
          result[:display_merger_volume] = clip_text(tbody, 2, 11 + offset)  # 表示合併号数
          result[:display_sub_volume] = clip_text(tbody, 2, 12 + offset)  # 補助号数
          result[:volume] = clip_text(tbody.css("tr:nth-child(#{13 + offset}) table > tbody > td:nth-child(2)"))  # 巻
          result[:volume2] = clip_text(tbody.css("tr:nth-child(#{13 + offset}) table > tbody > td:nth-child(4)"))  # 号
          result[:volume3] = clip_text(tbody.css("tr:nth-child(#{13 + offset}) table > tbody > td:nth-child(6)"))  # 通巻

          # 出版者、ページ数、価格
          tbody = doc.css('body > article > div.main > section:nth-child(2) > table > tbody')
          # NOTE: 「出版者名」部分のHTML構造の誤りにより要素番号をずらす必要がある。
          offset = 1
          # result[:publisher] = clip_text(tbody, 2, 1)  # 出版者名  # 取得できない
          result[:publisher2] = clip_text(tbody, 2, 3 + offset) # 発行人
          result[:publisher3] = clip_text(tbody, 2, 4 + offset) # 編集人
          result[:total_page] = clip_text(tbody, 2, 5 + offset) # ページ数
          result[:binding] = clip_text(tbody, 2, 6 + offset)  # 製本
          result[:category] = clip_text(tbody, 2, 7 + offset) # 分類
          result[:rating] = clip_text(tbody, 2, 8 + offset) # レイティング
          result[:size] = clip_text(tbody, 2, 9 + offset) # 縦の長さx横の長さ
          result[:price] = clip_text(tbody, 2, 10 + offset)  # 価格
          result[:magazine_code] = clip_text(tbody, 2, 11 + offset)  # 雑誌コード
          result[:tags] = clip_text(tbody, 2, 12 + offset) # タグ
          result[:note] = clip_text(tbody, 2, 13 + offset) # 備考

          # 目次
          result[:contents] = []
          doc.css('body > article > div.sub > section:nth-child(2) > table > tbody > tr').each do |tr|
            next if tr.css('td').empty?
            content = {}
            content[:category] = clip_text(tr, 1)
            # content[:title] = clip_text(tr.css('td:nth-child(2)'))  # magazine_work.titleを参照する
            content[:magazine_work] = MagazineWork.new(clip_id(tr, 2))
            # content[:author] = clip_text(tr, 3)  # magazine_work.authorを参照する
            content[:sub_title] = clip_text(tr, 4)
            content[:start_page] = clip_text(tr, 5)
            content[:total_page] = clip_text(tr, 6)
            content[:note] = clip_text(tr, 7)
            content[:format] = clip_text(tr, 8)
            result[:contents] << content
          end

          result
        end

        def parse_author(response_body)
          result = {}
          doc = Nokogiri::HTML.parse(response_body)
          tbody = doc.css('body > article > div.main > section > table > tbody')
          # NOTE: 「ID」部分のHTML構造の誤りにより要素番号をずらす必要がある。
          offset = 1
          result[:headings] = clip_text(tbody, 2, 2 + offset) # 標目
          result[:name] = clip_text(tbody, 2, 3 + offset) # 名称
          result[:name_kana] = clip_text(tbody, 2, 4 + offset)  # ヨミ
          result[:name_alphabet] = clip_text(tbody, 2, 5 + offset)  # ローマ字
          result[:reference_authors] = clip_authors(tbody, 2, 6 + offset)  # をも見よ参照
          result[:other_name] = clip_text(tbody, 2, 7 + offset) # 別名（表記ミス・ユレ、本名、新字旧字など）
          result[:birthday] = clip_text(tbody, 2, 8 + offset) # 生年月日(結成年月日)
          result[:death_date] = clip_text(tbody, 2, 9 + offset) # 没年月日

          result[:comic_work_quantity] = doc.css('body > article > div.sub > section:nth-child(1) > h3 > span').text
          result[:comic_works] = [] # 単行本化された作品 ※マンガ作品
          doc.css('body > article > div.sub > section:nth-child(1) table').each do |table|
            table.css('tr').each do |tr|
              next if tr.css('td').empty?
              content = {}
              # content[:author] = clip_text(tr, 2)
              result[:comic_works] << ComicWork.new(clip_id(tr, 1), content)
            end
          end

          result[:comic_title_quantity] = doc.css('body > article > div.sub > section:nth-child(2) > h3 > span').text
          result[:comic_titles] = []  # 単行本全巻
          doc.css('body > article > div.sub > section:nth-child(2) table').each do |table|
            table.css('tr').each do |tr|
              next if tr.css('td').empty?
              content = {}
              content[:title] = clip_text(tr, 1)
              # content[:author] = clip_text(tr, 2)
              content[:comic_quantity] = clip_text(tr, 3)
              result[:comic_titles] << ComicTitle.new(clip_id(tr, 1), content)
            end
          end

          # 資料、マンガ原画、その他の冊子、関連マンガ作品はサンプルが見つからないので未実装

          result
        end

        def parse_material(response_body)
          result = {}
          doc = Nokogiri::HTML.parse(response_body)
          tbody = doc.css('body > article > div.main > section > table > tbody')
          result[:title] = clip_text(tbody, 2, 2) # 資料名
          result[:title_kana] = clip_text(tbody, 2, 3) # 資料名ヨミ
          result[:discription] = clip_text(tbody, 2, 4)  # 詳細説明（説明文）
          result[:number] = clip_text(tbody, 2, 5)  # 順序
          result[:number_sort] = clip_text(tbody, 4, 5)  # 順序ソート
          result[:related_material_title] = clip_text(tbody, 2, 6) # 関連物（連携収蔵物）
          result[:cateogry] = clip_text(tbody, 2, 7) # 分類・カテゴリー
          result[:authority] = clip_text(tbody, 2, 8) # 責任表示
          result[:authority_kana] = clip_text(tbody, 2, 9) # 責任表示ヨミ
          result[:published_date] = clip_text(tbody, 2, 11) # 時期
          result[:created_date] = clip_text(tbody, 2, 12) # 作成（発行）地
          result[:quantity] = clip_text(tbody, 2, 13) # 数量
          result[:size] = clip_text(tbody, 2, 14) # 大きさ
          result[:condition] = clip_text(tbody, 2, 15) # 状態
          result[:langage] = clip_text(tbody, 2, 16) # 言語区分
          result[:code] = clip_text(tbody, 2, 17) # コード
          result[:tags] = clip_text(tbody, 2, 18) # タグ

          result
        end

        def parse_original_picture(response_body)
          result = {}
          doc = Nokogiri::HTML.parse(response_body)
          tbody = doc.css('body > article > div.main > section > table > tbody')
          result[:title] = clip_text(tbody, 2, 2) # 原画名
          result[:title_kana] = clip_text(tbody, 2, 3) # 原画ヨミ
          result[:volume] = clip_text(tbody, 2, 4)  # 順序
          result[:volume_sort_number] = clip_text(tbody, 4, 4)  # 順序ソート
          result[:total_page] = clip_text(tbody, 2, 5)  # 枚数
          result[:discription] = clip_text(tbody, 2, 6)  # 詳細説明（紹介文）
          result[:first_magazine_published] = clip_text(tbody, 2, 7) # 雑誌初出
          result[:recording] = clip_text(tbody, 2, 8) # 収録
          result[:authority] = clip_text(tbody, 2, 9) # 作画者・共著者
          result[:authority_kana] = clip_text(tbody, 2, 10) # 作画者・共著者ヨミ
          result[:authors] = clip_authors(tbody, 2, 11) # 著者典拠ID
          result[:created_date] = clip_text(tbody, 2, 12) # 執筆時期
          result[:size] = clip_text(tbody, 2, 13) # 大きさ
          result[:color] = clip_text(tbody, 2, 14) # 色数
          result[:painting_material] = clip_text(tbody, 2, 15) # 状態
          result[:condition] = clip_text(tbody, 2, 16) # 状態
          result[:langage] = clip_text(tbody, 2, 17) # 言語区分
          result[:tags] = clip_text(tbody, 2, 18) # タグ
          result[:comic_work] = ComicWork.new(clip_id(tbody, 2, 18)) # 作品ID

          result
        end

        def parse_booklet(response_body)
          result = {}
          doc = Nokogiri::HTML.parse(response_body)

          tbody = doc.css('body > article > div.main > section:nth-child(1) > table > tbody')
          result[:comic_work] = ComicWork.new(clip_id(tbody, 4, 1), {}) # （マンガ）作品ID
          result[:category] = clip_text(tbody, 2, 2)  # 分類
          result[:title] = clip_text(tbody, 2, 3)  # 冊子名
          result[:title_kana] = clip_text(tbody, 2, 4)  # ヨミ
          result[:title_append] = clip_text(tbody, 2, 5)  # 冊子名追記
          result[:title_append_kana] = clip_text(tbody, 2, 6)  # ヨミ
          result[:volume] = clip_text(tbody, 2, 7) # 巻
          result[:volume_sort_number] = clip_text(tbody, 4, 7)  # 巻ソート
          result[:title_other] = clip_text(tbody, 2, 8) # 冊子名別版表示
          result[:introduction] = clip_text(tbody, 2, 9)  # 紹介文

          tbody = doc.css('body > article > div.main > section:nth-child(2) > table > tbody')
          result[:authority] = clip_text(tbody, 2, 1)  # 責任表示
          result[:authors] = clip_authors(tbody, 2, 2)  # 著者典拠ID
          result[:author] = clip_text(tbody, 2, 3)  # 作者・著者
          result[:author_kana] = clip_text(tbody, 4, 3)
          result[:original] = clip_text(tbody, 2, 4)  # 原作・原案
          result[:original_kana] = clip_text(tbody, 4, 4)
          result[:collaborator] = clip_text(tbody, 2, 5)  # 協力者
          result[:collaborator_kana] = clip_text(tbody, 4, 5)
          result[:headings] = clip_text(tbody, 2, 6) # 標目

          tbody = doc.css('body > article > div.main > section:nth-child(3) > table > tbody')
          result[:publisher] = clip_text(tbody, 2, 1) # 出版者名（サークル名）
          result[:series] = clip_text(tbody, 2, 3)  # シリーズ
          result[:series_kana] = clip_text(tbody, 2, 4) # ヨミ
          result[:series_number] = clip_text(tbody, 2, 5) # シリーズ番号
          result[:published_event] = clip_text(tbody, 2, 6) # 頒布イベント

          tbody = doc.css('body > article > div.main > section:nth-child(4) > table > tbody')
          result[:published_data] = clip_text(tbody, 2, 1)  # 初版発行年月日
          result[:price] = clip_text(tbody, 4, 1)
          result[:published_data_note] = clip_text(tbody, 2, 2) # 発行日備考
          result[:japan_book_number] = clip_text(tbody, 2, 3) # 全国書誌番号
          result[:format] = clip_text(tbody, 2, 4)  # 製本・造本形態
          result[:total_page] = clip_text(tbody, 2, 5)  # ページ数
          result[:size] = clip_text(tbody, 4, 5)
          result[:published_area] = clip_text(tbody, 2, 6)  # 発行地
          result[:publisher2] = clip_text(tbody, 4, 6)
          result[:langage] = clip_text(tbody, 2, 7) # 言語区分
          result[:rating] = clip_text(tbody, 2, 8)  # レイティング
          result[:tags] = clip_text(tbody, 2, 9)  # タグ
          result[:note] = clip_text(tbody, 2, 10)  # 備考

          result
        end

        private

        def clip_text(node, td_number = nil, tr_number = nil)
          if td_number && tr_number
            node = node.css("tr:nth-child(#{tr_number}) > td:nth-child(#{td_number})")
          elsif td_number
            node = node.css("td:nth-child(#{td_number})")
          end
          text = node.css('a').empty? ? node.text : node.css('a').text
          # 改行を取り除き、半角スペースを削除、全角スペースを削除
          text.gsub!(/\n/, '')
          text.strip!
          text.gsub!(/^[　\s]*(.*?)[　\s]*$/, '\1')
        rescue
          nil
        end

        def clip_uri(node, td_number = nil, tr_number = nil)
          if td_number && tr_number
            node = node.css("tr:nth-child(#{tr_number}) > td:nth-child(#{td_number}) > a")
          elsif td_number
            node = node.css("td:nth-child(#{td_number}) > a")
          end
          node.attribute('href').value
        rescue
          nil
        end

        def clip_id(node, td_number = nil, tr_number = nil)
          uri = clip_uri(node, td_number, tr_number)
          # urlにqueryパラメータがある場合、?以降をを取り除く
          uri = uri[0...uri.index(/\?/)] if uri.include?('?')
          uri.slice(/[0-9]+$/)
        rescue
          nil
        end

        def has_id?(node, td_number = nil, tr_number = nil)
          if clip_id(node, td_number, tr_number)
            true
          else
            false
          end
        end

        def clip_authors(node, td_number = nil, tr_number = nil)
          authors = []
          if td_number && tr_number
            node = node.css("tr:nth-child(#{tr_number}) > td:nth-child(#{td_number}) > a")
          elsif td_number
            node = node.css("td:nth-child(#{td_number}) > a")
          end
          node.each do |a|
            # content = { :name => clip_text(a) } # textがnameではない場合もあるのでコメントアウト
            content = {}
            authors << Author.new(clip_id(a), content)
          end
          authors
        rescue
          []
        end

        # NOTE:
        # ISBN10は旧フォーマット。10桁の数字（最後は「X」の場合もある）
        # ISBN13は現行フォーマット。13桁の数字

        def clip_isbn10(node, td_number = nil, tr_number = nil)
          text = clip_text(node, td_number, tr_number)
          text.match(/\b[0-9X]{10}\b/).to_s
        rescue
          nil
        end

        def clip_isbn13(node, td_number = nil, tr_number = nil)
          text = clip_text(node, td_number, tr_number)
          text.match(/\b[0-9]{13}\b/).to_s
        rescue
          nil
        end
      end
    end
  end
end