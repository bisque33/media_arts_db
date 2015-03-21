require "net/http"
require "addressable/template"

module MediaArtsDb
  class HttpBase
    class << self
      def http_get(uri, query = nil)
        uri_obj = if query
                    template = Addressable::Template.new("#{uri}{?query*}")
                    template.expand(query)
                  else
                    Addressable::URI.parse(uri)
                  end
        # p uri_obj
        request(uri_obj)
      end

      private

      def request(uri_obj)
        begin
          response = Net::HTTP.get_response(uri_obj)
        rescue => e
          raise RuntimeError, "#{e.message}\n\n#{e.backtrace}"
        end
        response.code == '200' ? response.body : response_error(response)
      end

      def response_error(response)
        # 未実装
        nil
      end
    end
  end
end