module MediaArtsDb
  module Comic
    class Component
      attr_reader :id

      def initialize(id, content = {}, retrieved = false)
        @id = id
        @content = content
        @retrieved = retrieved
      end

      def [](key)
        if @content.has_key?(key)
          @content[key]
        else
          unless retrieved?
            @content.merge!(@retriever.execute.content)
            @retrieved = true
            @content.has_key?(key) ? @content[key] : nil
          end
        end
      end

      def method_missing(name, *args)
        self[name.to_sym]
      end

      def content
        unless retrieved?
          @content.merge!(@retriever.execute.content)
          @retrieved = true
        end
        @content
      end

      def content_cache
        @content
      end

      private

      def retrieved?
        @retrieved
      end
    end

    # NOTE:
    # すべてのコンポーネントをComponentクラスだけで表現することも可能であるが、
    # コンポーネントを区別する手段として一番わかり易いのがクラスを分けることだと思うので、
    # 冗長ではあるがコンポーネントの種類ごとにクラスを作成する。

    class ComicWork < Component
      def initialize(id, content = {}, retrieved = false)
        super(id, content, retrieved)
        @retriever = FindComicWork.new(@id)
      end
    end

    class ComicTitle < Component
      def initialize(id, content = {}, retrieved = false)
        super(id, content, retrieved)
        @retriever = FindComicTitle.new(@id)
      end
    end

    class Comic < Component
      def initialize(id, content = {}, retrieved = false)
        super(id, content, retrieved)
        @retriever = FindComic.new(@id)
      end

      def next
        # YAGNI
      end

      def prev
        # YAGNI
      end
    end

    class MagazineWork < Component
      def initialize(id, content = {}, retrieved = false)
        super(id, content, retrieved)
        @retriever = FindMagazineWork.new(@id)
      end
    end

    class MagazineTitle < Component
      def initialize(id, content = {}, retrieved = false)
        super(id, content, retrieved)
        @retriever = FindMagazineTitle.new(@id)
      end
    end

    class Magazine < Component
      def initialize(id, content = {}, retrieved = false)
        super(id, content, retrieved)
        @retriever = FindMagazine.new(@id)
      end

      def next
        # YAGNI
      end

      def prev
        # YAGNI
      end
    end

    class Author < Component
      def initialize(id, content = {}, retrieved = false)
        super(id, content, retrieved)
        @retriever = FindAuthor.new(@id)
      end
    end

    class Material < Component
      def initialize(id, content = {}, retrieved = false)
        super(id, content, retrieved)
        @retriever = FindMaterial.new(@id)
      end
    end

    class OriginalPicture < Component
      def initialize(id, content = {}, retrieved = false)
        super(id, content, retrieved)
        @retriever = FindOriginalPicture.new(@id)
      end
    end

    class Booklet < Component
      def initialize(id, content = {}, retrieved = false)
        super(id, content, retrieved)
        @retriever = FindBooklet.new(@id)
      end
    end
  end
end