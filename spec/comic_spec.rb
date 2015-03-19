require 'spec_helper'

describe MediaArtsDb::Comic do
  # describe Comic do
    context '#find_title' do
      before do
        @comic = MediaArtsDb::Comic::Comic.new
      end

      it '引数がない場合' do
        results = @comic.find_title()
        expect(results.count).to be 0
      end

      it 'タイトルがある場合' do
        results = @comic.find_title('カードキャプター')
        expect(results.count).to be 5
        expect(results[0][:title]).to eq 'カードキャプターさくら'
        expect(results[0][:type]).to eq 'comic'
        expect(results[0][:comic_works_id]).to eq '70232'
      end

    end

  # end
end
