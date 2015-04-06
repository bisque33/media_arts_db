require 'spec_helper'

include MediaArtsDb::Comic

describe MediaArtsDb::Comic::SearchOptionBuilder do
  describe '#build' do
    context 'target nil' do
      it 'raise error' do
        option = MediaArtsDb::Comic::SearchOptionBuilder.new
        expect{option.build}.to raise_error
      end
    end
    context 'target and options' do
      it 'returns hash' do
        option = MediaArtsDb::Comic::SearchOptionBuilder.new
        option.target_comic
        option.option_title = 'さくら'
        result = option.build
        # pp result
        expect(result['msf[select1]']).to eq 2
        expect(result['msf[text1]']).to eq 'さくら'
      end
    end
  end
end

describe MediaArtsDb::Comic::Search do
  describe 'target comic' do
    describe '#execute' do
      before :all do
        option = MediaArtsDb::Comic::SearchOptionBuilder.new
        option.target_comic
        option.option_title = 'さくら'
        search = MediaArtsDb::Comic::Search.new(option)
        @result = search.execute
        # pp @result
      end
      it 'returns array' do
        expect(@result.class).to eq Array
      end
      it 'returns ComicWorks in array' do
        expect(@result.map {|r| r.class }.include?(Comic)).to be true
      end
    end
  end
  describe 'target magazine' do
    describe '#execute' do
      before :all do
        option = MediaArtsDb::Comic::SearchOptionBuilder.new
        option.target_magazine
        option.option_volume_number_with_magazine = 999
        search = MediaArtsDb::Comic::Search.new(option)
        @result = search.execute
        # pp @result
      end
      it 'returns array' do
        expect(@result.class).to eq Array
      end
      it 'returns ComicWorks in array' do
        expect(@result.map {|r| r.class }.include?(Magazine)).to be true
      end
    end
  end
  describe 'target material' do
    describe '#execute' do
      before :all do
        option = MediaArtsDb::Comic::SearchOptionBuilder.new
        option.target_material
        search = MediaArtsDb::Comic::Search.new(option)
        @result = search.execute
        # pp @result
      end
      it 'returns array' do
        expect(@result.class).to eq Array
      end
      it 'returns ComicWorks in array' do
        expect(@result.map {|r| r.class }.include?(Material)).to be true
      end
    end
  end
  describe 'target original picture' do
    describe '#execute' do
      before :all do
        option = MediaArtsDb::Comic::SearchOptionBuilder.new
        option.target_original_picture
        search = MediaArtsDb::Comic::Search.new(option)
        @result = search.execute
        # pp @result
      end
      it 'returns array' do
        expect(@result.class).to eq Array
      end
      it 'returns ComicWorks in array' do
        expect(@result.map {|r| r.class }.include?(OriginalPicture)).to be true
      end
    end
  end
  describe 'target booklet' do
    describe '#execute' do
      before :all do
        option = MediaArtsDb::Comic::SearchOptionBuilder.new
        option.target_booklet
        search = MediaArtsDb::Comic::Search.new(option)
        @result = search.execute
        # pp @result
      end
      it 'returns array' do
        expect(@result.class).to eq Array
      end
      it 'returns ComicWorks in array' do
        expect(@result.map {|r| r.class }.include?(Booklet)).to be true
      end
    end
  end
end

describe MediaArtsDb::Comic::SearchWork do
  describe '#execute' do
    before :all do
      search = MediaArtsDb::Comic::SearchWork.new('カードキャプター')
      @result = search.execute
      # pp @result
    end
    it 'returns array' do
      expect(@result.class).to eq Array
    end
    it 'returns ComicWorks in array' do
      expect(@result.map {|r| r.class }.include?(ComicWork)).to be true
    end
    it 'returns MagazineWorks in array' do
      expect(@result.map {|r| r.class }.include?(MagazineWork)).to be true
    end
  end
end

describe MediaArtsDb::Comic::SearchMagazine do
  describe '#execute' do
    before :all do
      search = MediaArtsDb::Comic::SearchMagazine.new('なかよし')
      @result = search.execute
      # pp @result
    end
    it 'returns array' do
      expect(@result.class).to eq Array
    end
    it 'returns ComicWorks in array' do
      expect(@result.map {|r| r.class }.include?(MagazineTitle)).to be true
    end
  end
end

describe MediaArtsDb::Comic::SearchAuthor do
  describe '#execute' do
    before :all do
      search = MediaArtsDb::Comic::SearchAuthor.new('CLAMP')
      @result = search.execute
      # pp @result
    end
    it 'returns array' do
      expect(@result.class).to eq Array
    end
    it 'returns ComicWorks in array' do
      expect(@result.map {|r| r.class }.include?(Author)).to be true
    end
  end
end