# MediaArtsDb

media_arts_db is RubyGem to scraping to the MediaArtsDataBase(メディア芸術データベース: http://mediaarts-db.jp/).

[![Build Status](https://travis-ci.org/bisque33/media_arts_db.svg?branch=master)](https://travis-ci.org/bisque33/media_arts_db)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'media_arts_db'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install media_arts_db

## Usage

### Comic

Search and find the information from the Comic Database.
(「マンガ」データベースから情報を検索したり見つけたりします。)

```ruby
# 作品名(TITLE)で検索
results = MediaArtsDb::Comic.search_by_keyword title: 'カードキャプター'
# => 検索結果は、comic_works_id(マンガ単行本作品情報のID) または magazine_works_id(マンガ雑誌作品情報のID) が返る

# 雑誌名(MAGAZINE)で検索
results = MediaArtsDb::Comic.search_by_keyword magazine: 'なかよし'
# => 検索結果は、magazine_titles_id(マンガ雑誌基本情報のID) が返る

# 著者名(AUTHOR)で検索
results = MediaArtsDb::Comic.search_by_keyword author: 'CLAMP'
# => 検索結果は、author_id(著者情報のID) または magazine_works_id(マンガ雑誌作品情報のID) が返る
```

```ruby
# 単行本・雑誌・資料(SOURCE)で検索
# キーワード引数 targer: は、どの結果を取得するかを指定する。使用できる定数はMediaArtsDb::ComicSearchOption::TARGET_XXX に定義されている。省略した場合は「単行本」となる
# キーワード引数 options: は、検索条件を指定する。使用できるオプションは MediaArtsDb::ComicSearchOption に定義されている
target = MediaArtsDb::ComicSearchOption::TARGET_COMIC
options = { MediaArtsDb::ComicSearchOption::TITLE => 'カードキャプター' }
results = MediaArtsDb::Comic.search_by_source target: target, options: options
# => 検索結果は、targetにより以下が返る
# - TARGET_BOOKの場合、comic_id(マンガ単行本情報のID)
# - TARGET_MAGAZINEの場合、magazine_id(マンガ雑誌情報のID)
# - TARGET_MATERIALの場合、material_id(資料情報のID)
# - TARGET_ORIGINAL_PICTUREの場合、original_picture_id(マンガ原画情報のID)
# - TARGET_BOOKLETの場合、booklet_id(その他冊子情報のID)
```

```ruby
# comic_works(マンガ単行本作品情報)の詳細情報取得
result = MediaArtsDb::Comic.find_comic_works(comic_works_id)
# book_titles(マンガ単行本全巻情報)の詳細情報取得
result = MediaArtsDb::Comic.find_comic_titles(comic_titles_id)
# book(マンガ単行本情報)の詳細情報取得
result = MediaArtsDb::Comic.find_comic(comic_id)
# comic_works(マンガ雑誌作品情報)の詳細情報取得
result = MediaArtsDb::Comic.find_magazine_works(magazine_works_id)
# book_titles(マンガ雑誌全巻情報)の詳細情報取得
result = MediaArtsDb::Comic.find_magazine_titles(magazine_titles_id)
# book(マンガ雑誌情報)の詳細情報取得
result = MediaArtsDb::Comic.find_magazine(magazine_id)
# book(著者情報)の詳細情報取得
result = MediaArtsDb::Comic.find_author(author_id)
# book(資料情報)の詳細情報取得
result = MediaArtsDb::Comic.find_material(material_id)
# book(原画情報)の詳細情報取得
result = MediaArtsDb::Comic.find_original_picture(original_picture_id)
# book(その他冊子情報)の詳細情報取得
result = MediaArtsDb::Comic.find_booklet(booklet_id)
```

```ruby
# ページング
# search_by_keyword / search_by_source / find_book_titles はキーワード引数 :per :page にて検索結果の件数指定やページ指定が可能
# :per の既定は100、:page の既定は1
MediaArtsDb::Comic.search_by_keyword title: 'カードキャプター', per: 10, page: 2 # => 11〜20件目の検索結果
```

### Animation

Not implemented(未実装)

### Game

Not implemented(未実装)

### MediaArt

Not implemented(未実装)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec media_arts_db` to use the code located in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/media_arts_db/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
