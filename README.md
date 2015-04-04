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

```ruby
# 作品名(TITLE)で検索
search = MediaArtsDb::Comic::SearchWork.new('カードキャプター')
search.execute
# => 検索結果は、ComicWork(マンガ単行本作品情報)とMagazineWork(マンガ雑誌作品情報)が混在する配列が返る

# 雑誌名(MAGAZINE)で検索
search = MediaArtsDb::Comic::SearchMagazine.new('なかよし', per: 10)
search.execute
# => 検索結果は、MagazineTitle(マンガ雑誌基本情報)の配列が返る（1-10件目）

# 著者名(AUTHOR)で検索
search = MediaArtsDb::Comic::SearchMagazine.new('CLAMP', per: 10, page: 2)
search.execute
# => 検索結果は、Author(著者情報)の配列が返る（11-20件目）
```

```ruby
# 単行本・雑誌・資料(SOURCE)で検索
# まず検索条件を指定するためにSearchOptionBuilderクラスにパラメータを設定する
# .target_xxxはどの検索結果を取得するかの設定で、必須項目
# .option_xxxは検索条件で、サイトの制限により最大5個まで設定できる。また、条件を削除する場合はnilを代入する
option = MediaArtsDb::Comic::SearchOptionBuilder.new
option.target_comic
option.option_title = 'さくら'
# SearchクラスにSearchOptionBuilderを渡す。per:, page:の指定も可能
search = MediaArtsDb::Comic::Search.new(option)
@result = search.execute
# => 検索結果は、targetの設定により以下が返る
# - option.target_comicの場合、Comic(マンガ単行本情報)の配列が返る
# - option.target_magazineの場合、Magazine(マンガ雑誌情報)の配列が返る
# - option.target_materialの場合、Material(資料情報)の配列が返る
# - option.target_original_pictureの場合、OriginalPicture(マンガ原画情報)の配列が返る
# - option.target_bookletの場合、Booklet(その他冊子情報)の配列が返る
```

```ruby
# ComicWork(マンガ単行本作品情報)の詳細情報取得
result = MediaArtsDb::Comic::FindComicWork.new(comic_work_id)
# ComicTitle(マンガ単行本全巻情報)の詳細情報取得
result = MediaArtsDb::Comic::FindComicTitle.new(comic_title_id)
# Comic(マンガ単行本情報)の詳細情報取得
result = MediaArtsDb::Comic::FindComic.new(comic_id)
# MagazineWork(マンガ雑誌作品情報)の詳細情報取得
result = MediaArtsDb::Comic::FindMagazineWork.new(magazine_works_id)
# MagazineTitle(マンガ雑誌全巻情報)の詳細情報取得
result = MediaArtsDb::Comic::FindMagazineTitle.new(magazine_titles_id)
# Magazine(マンガ雑誌情報)の詳細情報取得
result = MediaArtsDb::Comic::FindMagazine.new(magazine_id)
# Author(著者情報)の詳細情報取得
result = MediaArtsDb::Comic::FindAuthor.new(author_id)
# Material(資料情報)の詳細情報取得
result = MediaArtsDb::Comic::FindMaterial.new(material_id)
# OriginalPicture(原画情報)の詳細情報取得
result = MediaArtsDb::Comic::FindOriginalPicture.new(original_picture_id)
# Booklet(その他冊子情報)の詳細情報取得
result = MediaArtsDb::Comic::FindBooklet.new(booklet_id)
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
