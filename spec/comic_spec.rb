require 'spec_helper'

include MediaArtsDb
include MediaArtsDb::ComicSearchOption

describe MediaArtsDb::Comic do
  describe '#search_by_keyword' do
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
      it 'has many values as a comic_works' do
        @results.each do |result|
          if result[:type] == 'comic_works'
            expect(result[:title]).to be_truthy
            expect(result[:type]).to eq 'comic_works'
            expect(result[:comic_works_id]).to be_truthy
            expect(result[:magazine_works_id]).to be_nil
            expect(result[:auther]).to be_truthy
            expect(result[:tags]).to be_truthy
            expect(result[:total_comic_volume]).to be_truthy
            expect(result[:total_magazine_volume]).to be_truthy
            expect(result[:documents]).to be_truthy
            expect(result[:original_picture]).to be_truthy
            expect(result[:other]).to be_truthy
            break
          end
        end
      end
      it 'has many values as a magazine_works' do
        @results.each do |result|
          if result[:type] == 'magazine_works'
            expect(result[:title]).to be_truthy
            expect(result[:type]).to eq 'magazine_works'
            expect(result[:comic_works_id]).to be_nil
            expect(result[:magazine_works_id]).to be_truthy
            expect(result[:auther]).to be_truthy
            expect(result[:tags]).to be_truthy
            expect(result[:total_comic_volume]).to be_truthy
            expect(result[:total_magazine_volume]).to be_truthy
            expect(result[:documents]).to be_truthy
            expect(result[:original_picture]).to be_truthy
            expect(result[:other]).to be_truthy
            break
          end
        end
      end
    end

    context 'parameter :magazine but no hit' do
      it 'returns empty array' do
        results = Comic.search_by_keyword magazine: '該当なし'
        expect(results).to eq []
      end
    end
    context 'parameter :magazine' do
      before do
        @results = Comic.search_by_keyword magazine: 'なかよし'
      end
      it 'returns many results' do
        expect(@results.count).not_to eq 0
      end
      it 'has many values' do
        result = @results.first
        expect(result[:type]).to eq 'magazine_titles'
        expect(result[:title]).to be_truthy
        expect(result[:magazine_titles_id]).to be_truthy
        expect(result[:publisher]).to be_truthy
        expect(result[:published_cycle]).to be_truthy
        expect(result[:published_start_date]).to be_truthy
        expect(result[:published_end_date]).to be_truthy
        expect(result[:tags]).to be_truthy
      end
    end

    context 'parameter :author but no hit' do
      it 'returns empty array' do
        results = Comic.search_by_keyword author: '該当なし'
        expect(results).to eq []
      end
    end
    context 'parameter :author' do
      before do
        @results = Comic.search_by_keyword author: '冨樫'
      end
      it 'returns many results' do
        expect(@results.count).not_to eq 0
      end
      it 'has many values as a authority' do
        @results.each do |result|
          if result[:type] == 'authority'
            expect(result[:type]).to eq 'authority'
            expect(result[:authority_id]).to be_truthy
            expect(result[:authority_name]).to be_truthy
            expect(result[:authority_name_kana]).to be_truthy
            expect(result[:related_authority_name]).to be_truthy
            expect(result[:book_title_quantity]).to be_truthy
            expect(result[:magazine_works_name]).to be_truthy
            expect(result[:magazine_works_id]).to be_nil
            break
          end
        end
      end
      it 'has many values as a magazine_works' do
        @results.each do |result|
          if result[:type] == 'magazine_works'
            expect(result[:type]).to eq 'magazine_works'
            expect(result[:authority_id]).to be_nil
            expect(result[:authority_name]).to be_truthy
            expect(result[:authority_name_kana]).to be_truthy
            expect(result[:related_authority_name]).to be_truthy
            expect(result[:book_title_quantity]).to be_truthy
            expect(result[:magazine_works_name]).to be_truthy
            expect(result[:magazine_works_id]).to be_truthy
            break
          end
        end
      end
      it 'has many values as a none' do
        @results.each do |result|
          if result[:type] == 'none'
            expect(result[:type]).to eq 'none'
            expect(result[:authority_id]).to be_nil
            expect(result[:authority_name]).to be_truthy
            expect(result[:authority_name_kana]).to be_truthy
            expect(result[:related_authority_name]).to be_truthy
            expect(result[:book_title_quantity]).to be_truthy
            expect(result[:magazine_works_name]).to be_truthy
            expect(result[:magazine_works_id]).to be_nil
            break
          end
        end
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

  describe '#search_by_source' do
    context 'parameter options TITLE' do
      it 'returns many records' do
        options = {ComicSearchOption::TITLE => 'カードキャプター'}
        results = Comic.search_by_source options: options
        expect(results.count).not_to be 0
      end
    end
    context 'parameter options TITLE and VOLUME' do
      it 'returns many records' do
        options = {
            ComicSearchOption::TITLE => 'カードキャプター',
            ComicSearchOption::VOLUME => 1
        }
        results = Comic.search_by_source options: options
        expect(results.count).not_to be 0
      end
    end
    context 'paramater options ID' do
      it 'returns one record' do
        options = {ComicSearchOption::ID => '4063197433'}
        results = Comic.search_by_source options: options
        expect(results.count).to be 1
        expect(results[0][:title]).to eq 'カードキャプターさくら'
        expect(results[0][:volume]).to eq '1'
      end
    end
    context 'paramater :per' do
      it 'returns 3 results' do
        options = {ComicSearchOption::TITLE => 'カードキャプター'}
        results = Comic.search_by_source options: options, per: 3
        expect(results.count).to eq 3
      end
    end
    context 'paramater :page' do
      it 'returns 100 results' do
        options = {ComicSearchOption::TITLE => 'さくら'}
        results = Comic.search_by_source options: options, page: 3
        expect(results.count).to eq 100
      end
    end
    context 'paramater :per and :page' do
      it 'returns 50 results' do
        options = {ComicSearchOption::TITLE => 'さくら'}
        results = Comic.search_by_source options: options, per: 50, page: 3
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
