require 'spec_helper'

include MediaArtsDb::Comic

describe MediaArtsDb::Comic do
  describe '#search_work' do
    before do
      search_work = MediaArtsDb::Comic.search_work('カードキャプター')
      @result = search_work.execute
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