require 'spec_helper'

include MediaArtsDb::Comic

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
        p result
        expect(result.id).to be_truthy
        expect(result.content).to be_truthy
        expect(result[:title]).to be_truthy
        expect(result[:title_kana]).to be_truthy
        expect(result[:not_exists]).to be nil
        expect(result.title).to be_truthy
        expect(result.title_kana).to be_truthy
        expect(result.not_exists).to be nil

        break
      end
    end
  end
end