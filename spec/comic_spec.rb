require 'spec_helper'

include MediaArtsDb
include MediaArtsDb::ComicSearchOption

describe MediaArtsDb::Comic do
  describe '#title_search' do
    context 'parameter nothing' do
      it 'returns empty array.' do
        results = Comic.search_by_keyword
        expect(results).to eq []
      end
    end
    context 'parameter :title but no hit' do
      it 'returns empty array' do
        results = Comic.search_by_keyword title: '該当なし'
        expect(results).to eq []
      end
    end

    context 'parameter :title' do
      before do
        @results = Comic.search_by_keyword title: 'カードキャプター'
      end
      it 'returns 5 results' do
        expect(@results.count).to eq 5
      end
      it 'has values as a comic_works' do
        result = @results[0]
        expect(result[:title]).to eq 'カードキャプターさくら'
        expect(result[:type]).to eq 'comic'
        expect(result[:comic_works_id]).to eq '70232'
        expect(result[:auther]).to eq '[著]CLAMP'
        expect(result[:tags]).to eq '-'
        expect(result[:total_comic_volume]).to eq '10件'
        expect(result[:total_magazine_volume]).to eq '4件'
        expect(result[:documents]).to eq '-'
        expect(result[:original_picture]).to eq '-'
        expect(result[:other]).to eq '-'
      end
      it 'has values as a magazine_works' do
        result = @results[2]
        expect(result[:title]).to eq 'カードキャプターさくら'
        expect(result[:type]).to eq 'magazine'
        expect(result[:comic_works_id]).to eq nil
        expect(result[:auther]).to eq 'CLAMP'
        expect(result[:tags]).to eq '-'
        expect(result[:total_comic_volume]).to eq '-'
        expect(result[:total_magazine_volume]).to eq '4件'
        expect(result[:documents]).to eq '-'
        expect(result[:original_picture]).to eq '-'
        expect(result[:other]).to eq '-'
      end
    end
    context 'paramater :per' do
      it 'returns 3 results' do
        @results = Comic.search_by_keyword title: 'カードキャプター', per: 3
        expect(@results.count).to eq 3
      end
    end
    context 'paramater :page' do
      it 'returns 100 results' do
        @results = Comic.search_by_keyword title: 'さくら', page: 3
        expect(@results.count).to eq 100
      end
    end
    context 'paramater :per and :page' do
      it 'returns 1 results' do
        @results = Comic.search_by_keyword title: 'カードキャプター', per:2, page: 3
        expect(@results.count).to eq 1
      end
    end

  end

  describe '#search_book' do
    context 'parameter options TITLE' do
      it 'returns many records' do
        options = {ComicSearchOption::TITLE => 'カードキャプター'}
        results = Comic.search_book options: options
        expect(results.count).not_to be 0
      end
    end
    context 'parameter options TITLE and VOLUME' do
      it 'returns many records' do
        options = {
            ComicSearchOption::TITLE => 'カードキャプター',
            ComicSearchOption::VOLUME => 1
        }
        results = Comic.search_book options: options
        expect(results.count).not_to be 0
      end
    end
    context 'paramater options ID' do
      it 'returns one record' do
        options = {ComicSearchOption::ID => '4063197433'}
        results = Comic.search_book options: options
        expect(results.count).to be 1
        expect(results[0][:title]).to eq 'カードキャプターさくら'
        expect(results[0][:volume]).to eq '1'
      end
    end
    context 'paramater :per' do
      it 'returns 3 results' do
        options = {ComicSearchOption::TITLE => 'カードキャプター'}
        results = Comic.search_book options: options, per: 3
        expect(results.count).to eq 3
      end
    end
    context 'paramater :page' do
      it 'returns 100 results' do
        options = {ComicSearchOption::TITLE => 'さくら'}
        results = Comic.search_book options: options, page: 3
        expect(results.count).to eq 100
      end
    end
    context 'paramater :per and :page' do
      it 'returns 50 results' do
        options = {ComicSearchOption::TITLE => 'さくら'}
        results = Comic.search_book options: options, per: 50, page: 3
        expect(results.count).to eq 50
      end
    end
  end

  describe '#find_comic_work' do
    context 'parameter nothing' do
    end


    context 'parameter id but no hit' do
      it 'returns empty hash' do
        result = Comic.find_comic_works('00000')
        expect(result.class).to eq Hash
      end
    end

    context 'parameter is exists id' do
      it 'returns something' do
        result = Comic.find_comic_works('70232')
        expect(result.class).to eq Hash
      end
    end

  end

end
