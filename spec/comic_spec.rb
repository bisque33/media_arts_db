require 'spec_helper'

describe MediaArtsDb::Comic do

  describe '#title_search' do

    context 'parameter nothing' do
      it 'returns empty array.' do
        results = MediaArtsDb::Comic.title_search()
        expect(results).to eq []
      end
    end

    context 'parameter title' do

      it 'returns 5 results' do
        results = MediaArtsDb::Comic.title_search('カードキャプター')
        expect(results.count).to be 5
        expect(results[0][:title]).to eq 'カードキャプターさくら'
        expect(results[0][:type]).to eq 'comic'
        expect(results[0][:comic_works_id]).to eq '70232'
      end
    end

  end

  describe '#find_comic_work' do
    context 'parameter nothing' do
    end


    context 'parameter not exists id' do
    end

    context 'parameter exists id' do
      it 'returns empty hash' do
        result = MediaArtsDb::Comic.find_comic_work('70232')
        expect(result.class).to eq Hash
        # expect(result.count).to be 1
      end
    end

  end

end
