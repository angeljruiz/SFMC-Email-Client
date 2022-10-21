module SFMC
  module Errors
    class BadRequestError < StandardError; end
    class UnauthorizedError < StandardError; end
    class ForbiddenError < StandardError; end
    class NotFoundError < StandardError; end
    class UnprocessableEntityError < StandardError; end
    class APIError < StandardError; end

    def error_class(code)
      case code.to_i
      when 400
        BadRequestError
      when 401
        UnauthorizedError
      when 403
        ForbiddenError
      when 404
        NotFoundError
      when 422
        UnprocessableEntityError
      else
        APIError
      end
    end

    def error_message(response)
      error = response.parsed_response
      documentation_msg = ", Documentation: #{error['documentation']}"
      add_documentation = !error['documentation'].nil?

      "#{response.code}, API error code: #{error['errorcode']}, Message: #{error['message']}" + (add_documentation ? documentation_msg : '')
    end
  end
end
