class ApiError < StandardError
  attr_reader :status, :code, :detail

  def initialize(status:, code:, detail:)
    @status = status
    @code = code
    @detail = detail
    super(detail)
  end
end
