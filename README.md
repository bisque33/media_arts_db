# MediaArtsDb

media_arts_db is RubyGem to scraping to the MediaArtsDataBase(メディア芸術データベース: http://mediaarts-db.jp/).

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

TODO: Write usage instructions here

### Comic

```ruby
# 作品名で検索
MediaArtsDb::Comic.search_by_keyword title: 'カードキャプター'
# 雑誌名で検索
MediaArtsDb::Comic.search_by_keyword magazine: 'なかよし'
# 著者名で検索
MediaArtsDb::Comic.search_by_keyword author: 'CLAMP'
# 単行本・雑誌・資料で検索
# キーワード引数 targer: どの結果を取得するかを指定する。省略した場合は「単行本」となる
# キーワード引数 options: で使用できるオプションは MediaArtsDb::ComicSearchOption に定義されている
target = MediaArtsDb::ComicSearchOption::TARGET_BOOK
options = { MediaArtsDb::ComicSearchOption::TITLE => 'カードキャプター' }
MediaArtsDb::Comic.search_by_source targer: target, options: options
# ページング
# search_by_keyword 及び search_by_source はキーワード引数 :per :page にて検索結果の件数指定やページ指定が可能
# :per の既定は100、:page の既定は1
MediaArtsDb::Comic.search_by_keyword title: 'カードキャプター', per: 10, page: 2 # => 11〜20件目の検索結果
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec media_arts_db` to use the code located in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/media_arts_db/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
