require 'spec_helper'

describe MediaArtsDb::Comic do

  describe '#title_search' do

    context 'parameter nothing' do
      it 'returns empty array.' do
        results = MediaArtsDb::Comic.search_by_keyword
        expect(results).to eq []
      end
    end

    context 'parameter title' do

      it 'returns 5 results' do
        results = MediaArtsDb::Comic.search_by_keyword title: 'カードキャプター'
        expect(results.count).to be 5
        expect(results[0][:title]).to eq 'カードキャプターさくら'
        expect(results[0][:type]).to eq 'comic'
        expect(results[0][:comic_works_id]).to eq '70232'
      end
    end

  end

  describe '#search_book' do
    context 'parameter title' do
      it 'returns 51 records' do
        options = {MediaArtsDb::ComicSearchOption::TITLE => 'カードキャプター'}
        results = MediaArtsDb::Comic.search_book options: options
        expect(results.count).to be 51
      end
    end
    context 'paramater isbn' do
      it 'returns 1 record' do
        options = {MediaArtsDb::ComicSearchOption::ID => '4063197433'}
        results = MediaArtsDb::Comic.search_book options: options
        expect(results.count).to be 1
        expect(results[0][:title]).to eq 'カードキャプターさくら'
        expect(results[0][:volume]).to eq '1'
      end
    end
  end

  describe '#find_comic_work' do
    context 'parameter nothing' do
    end


    context 'parameter is not exists id' do
      it 'returns empty hash' do
        result = MediaArtsDb::Comic.find_comic_works('00000')
        expect(result.class).to eq Hash
      end
    end

    context 'parameter is exists id' do
      it 'returns something' do
        result = MediaArtsDb::Comic.find_comic_works('70232')
        expect(result.class).to eq Hash
      end
    end

  end

end
