require "net/http"
require "addressable/template"

module MediaArtsDb
  class HttpBase
    def http_get(uri, query)
      template = Addressable::Template.new("#{uri}{?query*}")

      begin
        response = Net::HTTP.get_response(template.expand(query))
      rescue => e
        raise RuntimeError, "#{e.message}\n\n#{e.backtrace}"
      end

      response.code == '200' ? response.body : response_error(response)
    end

    private

    def response_error(response)
      # 未実装
      nil
    end
  end
end