require 'spec_helper'
require 'pp'

include MediaArtsDb::Comic
=begin
describe MediaArtsDb::Comic::RetrieveTemplate do
  describe '#execute' do
    it 'returns false' do
      request = RetrieveTemplate.new
      result = request.execute
      expect(result).to be false
    end
  end
  describe '#request' do
    it 'returns false' do
      request = RetrieveTemplate.new
      result = request.send(:request)
      expect(result).to be false
    end
  end
  describe '#parse' do
    it 'returns false' do
      request = RetrieveTemplate.new
      result = request.send(:parse, 'response_body')
      expect(result).to be false
    end
  end
  describe '#query_bilder' do
    it 'returns query' do
      request = RetrieveTemplate.new
      params = {keyword_title: 'カードキャプター', per: 100, page: 1}
      result = {query: {keyword_title: "カードキャプター", per: 100, page: 1, utf8: "✓", commit: "送信"}}
      expect(request.send(:query_builder, params)).to eq result
    end
  end
end

describe MediaArtsDb::Comic::SearchWork do
  describe '#execute' do
    it 'returns content' do
      request = SearchWork.new('カードキャプター')
      request.execute.each do |result|
        next unless result.class == ComicWork
        # pp result
        expect(result.id).to be_truthy
        expect(result.content).to be_truthy
        expect(result[:title]).to be_truthy
        expect(result[:title_kana]).to be_truthy
        expect(result[:not_exists]).to be nil
        expect(result.title).to be_truthy
        expect(result.title_kana).to be_truthy
        expect(result.not_exists).to be nil
        # pp result
        break
      end
    end
    it 'has 10 records' do
      request = SearchWork.new('あ', per: 10)
      expect(request.execute.count).to eq 10
    end
    it 'has 11 to 20 record' do
      request1 = SearchWork.new('あ', per: 1, page:1)
      request2 = SearchWork.new('あ', per: 1, page:2)
      expect(request1.execute.first.title).not_to eq request2.execute.first.title
    end
  end
end

describe MediaArtsDb::Comic::SearchMagazine do
  describe '#execute' do
    it 'returns content' do
      request = SearchMagazine.new('なかよし')
      request.execute.each do |result|
        # pp result
        expect(result.id).to be_truthy
        expect(result.content).to be_truthy
        expect(result[:title]).to be_truthy
        expect(result[:title_kana]).to be_truthy
        expect(result[:not_exists]).to be nil
        expect(result.title).to be_truthy
        expect(result.title_kana).to be_truthy
        expect(result.not_exists).to be nil
        # pp result
        break
      end
    end
    it 'has 10 records' do
      request = SearchMagazine.new('あ', per: 10)
      expect(request.execute.count).to eq 10
    end
    it 'has 11 to 20 record' do
      request1 = SearchMagazine.new('あ', per: 1, page:1)
      request2 = SearchMagazine.new('あ', per: 1, page:2)
      expect(request1.execute.first.title).not_to eq request2.execute.first.title
    end
  end
end

describe MediaArtsDb::Comic::SearchAuthor do
  describe '#execute' do
    it 'returns content' do
      request = SearchAuthor.new('CLAMP')
      request.execute.each do |result|
        # pp result
        expect(result.id).to be_truthy
        expect(result.content).to be_truthy
        expect(result[:name]).to be_truthy
        expect(result[:name_kana]).to be_truthy
        expect(result[:not_exists]).to be nil
        expect(result.name).to be_truthy
        expect(result.name_kana).to be_truthy
        expect(result.not_exists).to be nil
        # pp result
        break
      end
    end
    # データベースの内容が変更されるとテストが通らなくなる可能性あり
    it 'has 1 records' do
      request = SearchAuthor.new('冨樫義博', per: 1)
      expect(request.execute.count).to eq 1
    end
    it 'has 11 to 20 record' do
      request1 = SearchAuthor.new('冨樫義博', per: 1, page:1)
      request2 = SearchAuthor.new('冨樫義博', per: 1, page:2)
      expect(request1.execute.first.name).not_to eq request2.execute.first.name
    end
  end
end

describe MediaArtsDb::Comic::FindComicWork do
  describe '#execute' do
    before do
      request = FindComicWork.new(70232)
      @result = request.execute
    end
    it 'returns ComicWork' do
      expect(@result.class).to eq ComicWork
    end
    it 'returns content' do
      pp @result
      expect(@result.id).to be_truthy
      expect(@result.content).to be_truthy
      expect(@result[:title]).to be_truthy
      expect(@result[:title_kana]).to be_truthy
      expect(@result[:not_exists]).to be nil
      expect(@result.title).to be_truthy
      expect(@result.title_kana).to be_truthy
      expect(@result.not_exists).to be nil
    end
  end
end

describe MediaArtsDb::Comic::FindComicTitle do
  describe '#execute' do
    before do
      request = FindComicTitle.new(116315)
      @result = request.execute
    end
    it 'returns ComicTitle' do
      expect(@result.class).to eq ComicTitle
    end
    it 'returns content' do
      pp @result
      expect(@result.id).to be_truthy
      expect(@result.content).to be_truthy
      expect(@result[:title]).to be_truthy
      expect(@result[:title_kana]).to be_truthy
      expect(@result[:not_exists]).to be nil
      expect(@result.title).to be_truthy
      expect(@result.title_kana).to be_truthy
      expect(@result.not_exists).to be nil
    end
  end
end

describe MediaArtsDb::Comic::FindComic do
  describe '#execute' do
    before do
      request = FindComic.new(1216086)
      @result = request.execute
    end
    it 'returns Comic' do
      expect(@result.class).to eq Comic
    end
    it 'returns content' do
      pp @result
      expect(@result.id).to be_truthy
      expect(@result.content).to be_truthy
      expect(@result[:title]).to be_truthy
      expect(@result[:title_kana]).to be_truthy
      expect(@result[:not_exists]).to be nil
      expect(@result.title).to be_truthy
      expect(@result.title_kana).to be_truthy
      expect(@result.not_exists).to be nil
    end
  end
end

describe MediaArtsDb::Comic::FindMagazineWork do
  describe '#execute' do
    before do
      request = FindMagazineWork.new(14299)
      @result = request.execute
    end
    it 'returns MagazineWork' do
      expect(@result.class).to eq MagazineWork
    end
    it 'returns content' do
      pp @result
      expect(@result.id).to be_truthy
      expect(@result.content).to be_truthy
      expect(@result[:title]).to be_truthy
      expect(@result[:title_kana]).to be_truthy
      expect(@result[:not_exists]).to be nil
      expect(@result.title).to be_truthy
      expect(@result.title_kana).to be_truthy
      expect(@result.not_exists).to be nil
    end
  end
end

describe MediaArtsDb::Comic::FindMagazineTitle do
  describe '#execute' do
    before do
      request = FindMagazineTitle.new(14105)
      @result = request.execute
    end
    it 'returns MagazineTitle' do
      expect(@result.class).to eq MagazineTitle
    end
    it 'returns content' do
      pp @result
      expect(@result.id).to be_truthy
      expect(@result.content).to be_truthy
      expect(@result[:title]).to be_truthy
      expect(@result[:title_kana]).to be_truthy
      expect(@result[:not_exists]).to be nil
      expect(@result.title).to be_truthy
      expect(@result.title_kana).to be_truthy
      expect(@result.not_exists).to be nil
    end
  end
end

describe MediaArtsDb::Comic::FindMagazine do
  describe '#execute' do
    before do
      request = FindMagazine.new(380701)
      @result = request.execute
    end
    it 'returns Magazine' do
      expect(@result.class).to eq Magazine
    end
    it 'returns content' do
      pp @result
      expect(@result.id).to be_truthy
      expect(@result.content).to be_truthy
      expect(@result[:sub_title]).to be_truthy
      expect(@result[:sub_title_kana]).to be_truthy
      expect(@result[:not_exists]).to be nil
      expect(@result.sub_title).to be_truthy
      expect(@result.sub_title_kana).to be_truthy
      expect(@result.not_exists).to be nil
    end
  end
end

describe MediaArtsDb::Comic::FindAuthor do
  describe '#execute' do
    before do
      request = FindAuthor.new(6215)
      @result = request.execute
    end
    it 'returns Author' do
      expect(@result.class).to eq Author
    end
    it 'returns content' do
      pp @result
      expect(@result.id).to be_truthy
      expect(@result.content).to be_truthy
      expect(@result[:name]).to be_truthy
      expect(@result[:name_kana]).to be_truthy
      expect(@result[:not_exists]).to be nil
      expect(@result.name).to be_truthy
      expect(@result.name_kana).to be_truthy
      expect(@result.not_exists).to be nil
    end
  end
end

describe MediaArtsDb::Comic::FindMaterial do
  describe '#execute' do
    before do
      request = FindMaterial.new(227)
      @result = request.execute
    end
    it 'returns Material' do
      expect(@result.class).to eq Material
    end
    it 'returns content' do
      pp @result
      expect(@result.id).to be_truthy
      expect(@result.content).to be_truthy
      expect(@result[:title]).to be_truthy
      expect(@result[:title_kana]).to be_truthy
      expect(@result[:not_exists]).to be nil
      expect(@result.title).to be_truthy
      expect(@result.title_kana).to be_truthy
      expect(@result.not_exists).to be nil
    end
  end
end

describe MediaArtsDb::Comic::FindOriginalPicture do
  describe '#execute' do
    before do
      request = FindOriginalPicture.new(11)
      @result = request.execute
    end
    it 'returns OriginalPicture' do
      expect(@result.class).to eq OriginalPicture
    end
    it 'returns content' do
      pp @result
      expect(@result.id).to be_truthy
      expect(@result.content).to be_truthy
      expect(@result[:title]).to be_truthy
      expect(@result[:title_kana]).to be_truthy
      expect(@result[:not_exists]).to be nil
      expect(@result.title).to be_truthy
      expect(@result.title_kana).to be_truthy
      expect(@result.not_exists).to be nil
    end
  end
end
=end

describe MediaArtsDb::Comic::FindBooklet do
  describe '#execute' do
    before do
      request = FindBooklet.new(2)
      @result = request.execute
    end
    it 'returns Booklet' do
      expect(@result.class).to eq Booklet
    end
    it 'returns content' do
      pp @result
      expect(@result.id).to be_truthy
      expect(@result.content).to be_truthy
      expect(@result[:title]).to be_truthy
      expect(@result[:title_kana]).to be_truthy
      expect(@result[:not_exists]).to be nil
      expect(@result.title).to be_truthy
      expect(@result.title_kana).to be_truthy
      expect(@result.not_exists).to be nil
    end
  end
end