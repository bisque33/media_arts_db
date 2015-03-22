require 'spec_helper'

include MediaArtsDb
include MediaArtsDb::ComicSearchOption

describe MediaArtsDb::Comic do
=begin
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
            expect(result[:author]).to be_truthy
            expect(result[:tags]).to be_truthy
            expect(result[:total_comic_volume]).to be_truthy
            expect(result[:total_magazine_volume]).to be_truthy
            expect(result[:materials]).to be_truthy
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
            expect(result[:author]).to be_truthy
            expect(result[:tags]).to be_truthy
            expect(result[:total_comic_volume]).to be_truthy
            expect(result[:total_magazine_volume]).to be_truthy
            expect(result[:materials]).to be_truthy
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
        expect(result[:published_interval]).to be_truthy
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
            expect(result[:author_id]).to be_truthy
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
            expect(result[:author_id]).to be_nil
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
            expect(result[:author_id]).to be_nil
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
    describe 'TARGET_BOOK' do
      context 'parameter options TITLE but no hit' do
        it 'returns many records' do
          options = {ComicSearchOption::TITLE => '該当なし'}
          results = Comic.search_by_source options: options
          expect(results.count).to be 0
        end
      end
      context 'parameter options TITLE' do
        it 'returns many records' do
          options = {ComicSearchOption::TITLE => 'カードキャプター'}
          results = Comic.search_by_source options: options
          expect(results.count).not_to be 0
        end
        it 'has many values' do
          options = {ComicSearchOption::TITLE => 'カードキャプター'}
          results = Comic.search_by_source options: options
          expect(results[0][:type]).to eq 'book'
          expect(results[0][:isbn]).to be_truthy
          expect(results[0][:book_title]).to be_truthy
          expect(results[0][:book_id]).to be_truthy
          expect(results[0][:label]).to be_truthy
          expect(results[0][:volume]).to be_truthy
          expect(results[0][:author]).to be_truthy
          expect(results[0][:publisher]).to be_truthy
          expect(results[0][:published_date]).to be_truthy
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
          expect(results[0][:book_title]).to eq 'カードキャプターさくら'
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
    describe 'TARGET_MAGAZINE_VOLUME' do
      context 'parameter options TITLE but no hit' do
        it 'returns many records' do
          options = {ComicSearchOption::TITLE => '該当なし'}
          results = Comic.search_by_source target: ComicSearchOption::TARGET_MAGAZINE_VOLUME, options: options
          expect(results.count).to be 0
        end
      end
      context 'parameter options TITLE' do
        it 'returns many records' do
          options = {ComicSearchOption::TITLE => ''}
          results = Comic.search_by_source target: ComicSearchOption::TARGET_MAGAZINE_VOLUME, options: options
          expect(results.count).not_to be 0
        end
        it 'has many values' do
          options = {ComicSearchOption::TITLE => ''}
          results = Comic.search_by_source target: ComicSearchOption::TARGET_MAGAZINE_VOLUME, options: options
          expect(results[0][:type]).to eq 'magazine'
          expect(results[0][:magazine_title]).to be_truthy
          expect(results[0][:magazine_id]).to be_truthy
          expect(results[0][:volume]).to be_truthy
          expect(results[0][:display_volume]).to be_truthy
          expect(results[0][:display_sub_volume]).to be_truthy
          expect(results[0][:publisher]).to be_truthy
          expect(results[0][:published_date]).to be_truthy
        end
      end
    end
    describe 'TARGET_MATERIAL' do
      context 'parameter options TITLE but no hit' do
        it 'returns many records' do
          options = {ComicSearchOption::TITLE => '該当なし'}
          results = Comic.search_by_source target: ComicSearchOption::TARGET_MATERIAL, options: options
          expect(results.count).to be 0
        end
      end
      context 'parameter options TITLE' do
        it 'returns many records' do
          options = {ComicSearchOption::TITLE => ''}
          results = Comic.search_by_source target: ComicSearchOption::TARGET_MATERIAL, options: options
          expect(results.count).not_to be 0
        end
        it 'has many values' do
          options = {ComicSearchOption::TITLE => ''}
          results = Comic.search_by_source target: ComicSearchOption::TARGET_MATERIAL, options: options
          expect(results[0][:type]).to eq 'material'
          expect(results[0][:material_title]).to be_truthy
          expect(results[0][:material_id]).to be_truthy
          expect(results[0][:category]).to be_truthy
          expect(results[0][:number]).to be_truthy
          expect(results[0][:author]).to be_truthy
          expect(results[0][:related_material_title]).to be_truthy
          expect(results[0][:published_date]).to be_truthy
        end
      end
    end
    describe 'TARGET_ORIGINAL_PICTURE' do
      context 'parameter options TITLE but no hit' do
        it 'returns many records' do
          options = {ComicSearchOption::TITLE => '該当なし'}
          results = Comic.search_by_source target: ComicSearchOption::TARGET_ORIGINAL_PICTURE, options: options
          expect(results.count).to be 0
        end
      end
      context 'parameter options TITLE' do
        it 'returns many records' do
          options = {ComicSearchOption::TITLE => ''}
          results = Comic.search_by_source target: ComicSearchOption::TARGET_ORIGINAL_PICTURE, options: options
          expect(results.count).not_to be 0
        end
        it 'has many values' do
          options = {ComicSearchOption::TITLE => ''}
          results = Comic.search_by_source target: ComicSearchOption::TARGET_ORIGINAL_PICTURE, options: options
          expect(results[0][:type]).to eq 'original_picture'
          expect(results[0][:original_picture_title]).to be_truthy
          expect(results[0][:original_picture_id]).to be_truthy
          expect(results[0][:recorded]).to be_truthy
          expect(results[0][:number]).to be_truthy
          expect(results[0][:quantity]).to be_truthy
          expect(results[0][:author]).to be_truthy
          expect(results[0][:published_date]).to be_truthy
          expect(results[0][:writing_time]).to be_truthy
        end
      end
    end
    describe 'TARGET_BOOKLET' do
      context 'parameter options TITLE but no hit' do
        it 'returns many records' do
          options = {ComicSearchOption::TITLE => '該当なし'}
          results = Comic.search_by_source target: ComicSearchOption::TARGET_BOOKLET, options: options
          expect(results.count).to be 0
        end
      end
      context 'parameter options TITLE' do
        it 'returns many records' do
          options = {ComicSearchOption::TITLE => ''}
          results = Comic.search_by_source target: ComicSearchOption::TARGET_BOOKLET, options: options
          expect(results.count).not_to be 0
        end
        it 'has many values' do
          options = {ComicSearchOption::TITLE => ''}
          results = Comic.search_by_source target: ComicSearchOption::TARGET_BOOKLET, options: options
          expect(results[0][:type]).to eq 'booklet'
          expect(results[0][:booklet_title]).to be_truthy
          expect(results[0][:booklet_id]).to be_truthy
          expect(results[0][:series]).to be_truthy
          expect(results[0][:volume]).to be_truthy
          expect(results[0][:author]).to be_truthy
          expect(results[0][:publisher]).to be_truthy
          expect(results[0][:published_date]).to be_truthy
        end
      end
    end
  end

  describe '#find_comic_works' do
    context 'parameter id but no hit' do
      it 'returns empty hash' do
        result = Comic.find_comic_works('00000')
        expect(result.class).to eq Hash
      end
    end
    context 'parameter id' do
      it 'has many values' do
        result = Comic.find_comic_works('70232')
        expect(result[:comic_id]).to be_nil
        expect(result[:title]).to be_truthy
        expect(result[:title_kana]).to be_truthy
        expect(result[:sub_title]).to be_truthy
        expect(result[:title_alphabet]).to be_truthy
        expect(result[:author]).to be_truthy
        expect(result[:published_date]).to be_truthy
        expect(result[:source]).to be_truthy
        expect(result[:introduction]).to be_truthy
        expect(result[:category]).to be_truthy
        expect(result[:tags]).to be_truthy
        expect(result[:rating]).to be_truthy
        # expect(result[:author_author_id]).to be_truthy
        expect(result[:author_id]).to be_truthy
        expect(result[:book_titles]).to be_truthy
        expect(result[:magazine_works]).to be_truthy
      end
    end
  end

  describe '#find_book_titles' do
    context 'parameter id but no hit' do
      it 'returns empty hash' do
        result = Comic.find_book_titles('00000')
        expect(result.class).to eq Hash
      end
    end
    context 'parameter id' do
      it 'has many values' do
        result = Comic.find_book_titles('116326')
        expect(result[:comic_works_id]).to be_truthy
        expect(result[:title]).to be_truthy
        expect(result[:title_kana]).to be_truthy
        expect(result[:title_append]).to be_truthy
        expect(result[:title_append_kana]).to be_truthy
        expect(result[:title_other]).to be_truthy
        expect(result[:total_comic_volume]).to be_truthy
        expect(result[:responsible]).to be_truthy
        expect(result[:author_id]).to be_truthy
        expect(result[:author]).to be_truthy
        expect(result[:author_kana]).to be_truthy
        expect(result[:origina_title]).to be_truthy
        expect(result[:origina_title_kana]).to be_truthy
        expect(result[:collaborator]).to be_truthy
        expect(result[:collaborator_kana]).to be_truthy
        expect(result[:headings]).to be_truthy
        expect(result[:label]).to be_truthy
        expect(result[:label_kana]).to be_truthy
        expect(result[:series]).to be_truthy
        expect(result[:series_kana]).to be_truthy
        expect(result[:publisher]).to be_truthy
        expect(result[:published_area]).to be_truthy
        expect(result[:size]).to be_truthy
        expect(result[:isbn]).to be_truthy
        expect(result[:langage]).to be_truthy
        expect(result[:category]).to be_truthy
        expect(result[:rating]).to be_truthy
        expect(result[:introduction]).to be_truthy
        expect(result[:tags]).to be_truthy
        expect(result[:note]).to be_truthy

        expect(result[:books]).to be_truthy
        expect(result[:books][0][:title]).to be_truthy
        expect(result[:books][0][:book_id]).to be_truthy
        expect(result[:books][0][:book_title_append]).to be_truthy
        expect(result[:books][0][:volume]).to be_truthy
      end
    end
    context 'paramater :per' do
      it 'returns 3 results' do
        result = Comic.find_book_titles('116326', per: 3)
        expect(result[:books].count).to eq 3
      end
    end
    context 'paramater :per and :page' do
      it 'returns 5 results' do
        result = Comic.find_book_titles('116326', per:5, page: 2)
        expect(result[:books].count).to eq 5
      end
    end
  end
=end
  describe '#find_book' do
    context 'parameter id but no hit' do
      it 'returns empty hash' do
        result = Comic.find_book('00000')
        expect(result.class).to eq Hash
      end
    end
    context 'parameter id' do
      it 'has many values' do
        result = Comic.find_book('1216047')
        expect(result.class).to eq Hash
        expect(result[:basic_information]).to be_truthy
        expect(result[:author_information]).to be_truthy
        expect(result[:publisher_information]).to be_truthy
        expect(result[:other_information]).to be_truthy
        # p result
      end
    end
  end

  describe '#find_magazine_works' do
    context 'parameter id but no hit' do
      it 'returns empty hash' do
        result = Comic.find_magazine_works('00000')
        expect(result.class).to eq Hash
      end
    end
    context 'parameter id' do
      it 'has many values' do
        result = Comic.find_magazine_works('14299')
        expect(result.class).to eq Hash
        expect(result[:magazines]).to be_truthy
        # p result
      end
    end
  end

# =begin # 時間がかかるので通常はコメントアウト

  describe '#find_magazine_titles' do
    context 'parameter id but no hit' do
      it 'returns empty hash' do
        result = Comic.find_magazine_titles('00000')
        expect(result.class).to eq Hash
      end
    end
    context 'parameter id' do
      it 'has many values' do
        result = Comic.find_magazine_titles('10677')
        expect(result.class).to eq Hash
        expect(result[:magazines]).to be_truthy
        # p result
      end
    end
  end


  describe '#find_magazine_titles' do
    context 'parameter id but no hit' do
      it 'returns empty hash' do
        result = Comic.find_magazine('00000')
        expect(result.class).to eq Hash
      end
    end
    context 'parameter id' do
      it 'has many values' do
        result = Comic.find_magazine('381207')
        expect(result.class).to eq Hash
        expect(result[:contents]).to be_truthy
        # p result
      end
    end
  end
end
