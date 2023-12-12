class CreateRecordingsPayloadValidator
  class << self
    def valid?(params)
      # validates existence of required params
      return false if params[:id].nil? || params[:readings].nil?
      params[:readings].any? { |recording| is_recording_valid?(recording) }
    end

    def is_recording_valid?(recording)
      return false unless recording["count"].is_a? Integer
      begin
        Time.parse(recording["timestamp"])
      rescue ArgumentError => e
        return false
      end
    end
  end
end
