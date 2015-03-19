require "net/http"
require "addressable/template"

module MediaArtsDb
  class HttpBase
    def get(uri, query)
      uri_template = Addressable::Template.new("#{uri}{?query*}")
      uri_template.expand(query)

      begin
        response = Net::HTTP.get(uri_template.uri)
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