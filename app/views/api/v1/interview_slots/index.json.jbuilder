json.success true
json.data do
  time_format = INTERVIEW_SLOTS_CONFIG['free_mock_interview']['datetime_format']
  json.message @message
  json.slots @slots.each do |slot|
    json.id slot.id
    json.interviewer_email slot.interviewer.email
    json.start_datetime slot.start_datetime.strftime(time_format)
    json.end_datetime slot.end_datetime.strftime(time_format)
  end
end
