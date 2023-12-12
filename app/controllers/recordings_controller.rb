class RecordingsController < ApplicationController
  def create
    is_valid = CreateRecordingsPayloadValidator.valid?(params)
    if is_valid
      store = DataStore.get
      current_linked_list = store[params[:id]] || DoubleLinkedList.new
      params[:readings].each{|recording| current_linked_list.sorted_add(Time.parse(recording["timestamp"]), recording["count"])}
      DataStore.add(params[:id], current_linked_list)
      head :ok
    else
      render json: { message: "Malformed request"}, status: :bad_request
    end
  end

  def latest
    list_for_id = DataStore.get[params[:device_id]]
    if list_for_id.nil?
      render json: { message: "No recordings were found for that list" }, status: :not_found
    else
      render json: { latest_timestamp: list_for_id.head.timestamp }
    end
  end

  def cumulative_count
    list_for_id = DataStore.get[params[:device_id]]
    if list_for_id.nil?
      render json: { message: "No recordings were found for that list" }, status: :not_found
    else
      render json: { cumulative_count: list_for_id.total_count }
    end
  end
end
