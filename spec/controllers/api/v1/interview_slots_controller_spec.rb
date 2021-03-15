require 'rails_helper'

RSpec.describe Api::V1::InterviewSlotsController, type: :controller do
  let(:student) { FactoryBot.create(:user, email: Faker::Internet.email) }
  let(:interviewer) { FactoryBot.create(:user, email: Faker::Internet.email) }
  let(:interviewer_two) { FactoryBot.create(:user, email: Faker::Internet.email) }
  let(:student_start_datetime) { '2021-01-17T14:00:00' }
  let(:student_end_datetime) { '2021-01-17T18:00:00' }
  let(:interview_slot) do
    FactoryBot.create(
      :interview_slot,
      interviewer_id: interviewer.id,
      start_datetime: Time.zone.parse(student_start_datetime) + 1.hour,
      end_datetime: Time.zone.parse(student_start_datetime) + 2.hours
    )
  end
  let(:interview_slot_two) do
    FactoryBot.create(
      :interview_slot,
      interviewer_id: interviewer.id,
      start_datetime: Time.zone.parse(student_start_datetime) + 2.hours,
      end_datetime: Time.zone.parse(student_start_datetime) + 3.hours
    )
  end
  let(:interview_slot_three) do
    FactoryBot.create(
      :interview_slot,
      interviewer_id: interviewer.id,
      start_datetime: Time.zone.parse(student_start_datetime) - 5.hours,
      end_datetime: Time.zone.parse(student_start_datetime) - 4.hours,
      status: InterviewSlot.statuses[:completed]
    )
  end
  let(:interview_slot_four) do
    FactoryBot.create(
      :interview_slot,
      interviewer_id: interviewer_two.id,
      start_datetime: Time.zone.parse(student_start_datetime) + 1.hour,
      end_datetime: Time.zone.parse(student_start_datetime) + 2.hours
    )
  end
  let(:completed_interview) do
    FactoryBot.create(
      :interview,
      interviewee_id: student.id,
      interview_slot_id: interview_slot_three.id,
      status: Interview.statuses[:completed],
      grade: 3
    )
  end
  let(:scheduled_interview) do
    FactoryBot.create(
      :interview,
      interviewee_id: student.id,
      interview_slot_id: interview_slot_four.id,
      status: Interview.statuses[:scheduled]
    )
  end
  let(:user_not_found_error_msg) { 'User not found' }

  describe '#index' do
    let(:config) { INTERVIEW_SLOTS_CONFIG['free_mock_interview'] }
    let(:params) do
      {
        'studentId': student.id,
        'startDateTime': student_start_datetime,
        'endDateTime': student_end_datetime
      }
    end
    let(:missing_params_error_msg) do
      'Required params studentId, startDateTime, endDateTime are missing'
    end

    context 'with missing params' do
      it 'raises MissingParamsError' do
        get :index

        response_body = JSON.parse(response.body)

        expect(response.status).to eq(422)
        expect(response_body['success']).to be_falsey
        expect(response_body['exception']).to eq(missing_params_error_msg)
      end
    end

    context 'with missing user' do
      before do
        params['studentId'] = 0
      end

      it 'raises UserNotFoundError' do
        get :index, params: params, as: :json

        response_body = JSON.parse(response.body)

        expect(response.status).to eq(403)
        expect(response_body['success']).to be_falsey
        expect(response_body['exception']).to eq(user_not_found_error_msg)
      end
    end

    context 'with valid params' do
      context 'when all mocks already consumed' do
        before do
          config['limit'].times do
            FactoryBot.create(
              :interview,
              interview_slot_id: interview_slot.id,
              interviewee_id: student.id
            )
          end
        end

        it 'returns an empty array with free_limit_exhausted message' do
          message = 'Student has already scheduled all free mocks'

          get :index, params: params, as: :json

          response_body = JSON.parse(response.body)
          response_body_data = response_body['data']

          expect(response.status).to eq(200)
          expect(response_body['success']).to be_truthy
          expect(response_body_data['message']).to eq(message)
          expect(response_body_data['slots']).to eq([])
        end
      end

      context 'when previous 2 mocks below average grades' do
        before do
          config['no_of_latest_interviews_to_check'].times do
            FactoryBot.create(
              :interview,
              interview_slot_id: interview_slot.id,
              interviewee_id: student.id,
              status: Interview.statuses[:completed],
              grade: [0, 1].sample
            )
          end
        end

        it 'returns an empty array with less_grade message' do
          message = 'Due to poor performance in last 2 interviews, '\
                    'no more interviews can be scheduled'

          get :index, params: params, as: :json

          response_body = JSON.parse(response.body)
          response_body_data = response_body['data']

          expect(response.status).to eq(200)
          expect(response_body['success']).to be_truthy
          expect(response_body_data['message']).to eq(message)
          expect(response_body_data['slots']).to eq([])
        end
      end

      context 'when no interview slot is available' do
        it 'returns an empty array with no_slot_found message' do
          message = 'No Interview slot available for the chosen time range'

          get :index, params: params, as: :json

          response_body = JSON.parse(response.body)
          response_body_data = response_body['data']

          expect(response.status).to eq(200)
          expect(response_body['success']).to be_truthy
          expect(response_body_data['message']).to eq(message)
          expect(response_body_data['slots']).to eq([])
        end
      end

      let(:time_format) do
        INTERVIEW_SLOTS_CONFIG['free_mock_interview']['datetime_format']
      end
      let(:success_response_when_no_other_scheduled) do
        [
          {
            'id' => interview_slot.id,
            'interviewer_email' => interviewer.email,
            'start_datetime' => interview_slot.start_datetime
                                              .strftime(time_format),
            'end_datetime' => interview_slot.end_datetime
                                            .strftime(time_format)
          },
          {
            'id' => interview_slot_two.id,
            'interviewer_email' => interviewer.email,
            'start_datetime' => interview_slot_two.start_datetime
                                                  .strftime(time_format),
            'end_datetime' => interview_slot_two.end_datetime
                                                .strftime(time_format)
          }
        ]
      end

      context 'when interview slots are available' do
        context 'when no other scheduled interview' do
          before do
            [interview_slot, interview_slot_two]
          end

          it 'returns an array of available slots with empty message' do
            get :index, params: params, as: :json

            response_body = JSON.parse(response.body)
            response_body_data = response_body['data']

            expect(response.status).to eq(200)
            expect(response_body['success']).to be_truthy
            expect(response_body_data['message']).to eq('')
            expect(response_body_data['slots']).to eq(
              success_response_when_no_other_scheduled
            )
          end
        end

        context 'when the interviewer is same' do
          before do
            [interview_slot, completed_interview]
          end

          it 'returns an empty array with no_slot_found message' do
            message = 'No Interview slot available for the chosen time range'

            get :index, params: params, as: :json

            response_body = JSON.parse(response.body)
            response_body_data = response_body['data']

            expect(response.status).to eq(200)
            expect(response_body['success']).to be_truthy
            expect(response_body_data['message']).to eq(message)
            expect(response_body_data['slots']).to eq([])
          end
        end

        let(:success_response_when_other_scheduled) do
          [
            {
              'id' => interview_slot_two.id,
              'interviewer_email' => interviewer.email,
              'start_datetime' => interview_slot_two.start_datetime
                                                    .strftime(time_format),
              'end_datetime' => interview_slot_two.end_datetime
                                                  .strftime(time_format)
            }
          ]
        end

        context 'when there are other scheduled interview' do
          before do
            [interview_slot, interview_slot_two, interview_slot_three, scheduled_interview]
          end

          it 'returns available slots while filtering the clashes' do
            get :index, params: params, as: :json

            response_body = JSON.parse(response.body)
            response_body_data = response_body['data']

            expect(response.status).to eq(200)
            expect(response_body['success']).to be_truthy
            expect(response_body_data['message']).to eq('')
            expect(response_body_data['slots']).to eq(
              success_response_when_other_scheduled
            )
          end
        end
      end
    end
  end

  describe '#create' do
    let(:params) do
      {
        'studentId': student.id,
        'interviewSlotId': interview_slot.id
      }
    end
    let(:missing_params_error_msg) do
      'Required params studentId, interviewSlotId are missing'
    end
    let(:interview_slot_unavailable_error) do
      "Interview slot #{interview_slot_three.id} is unavailable. "\
      'Kindly book another slot'
    end
    let(:success_message) { 'Interview slot has been successfully scheduled.' }

    context 'with missing params' do
      it 'raises MissingParamsError' do
        post :create

        response_body = JSON.parse(response.body)

        expect(response.status).to eq(422)
        expect(response_body['success']).to be_falsey
        expect(response_body['exception']).to eq(missing_params_error_msg)
      end
    end

    context 'with missing user' do
      before do
        params['studentId'] = 0
      end

      it 'raises UserNotFoundError' do
        post :create, params: params, as: :json

        response_body = JSON.parse(response.body)

        expect(response.status).to eq(403)
        expect(response_body['success']).to be_falsey
        expect(response_body['exception']).to eq(user_not_found_error_msg)
      end
    end

    context 'with unavailable slot' do
      before do
        params['interviewSlotId'] = interview_slot_three.id
      end

      it 'raises InterviewSlotUnavailableError' do
        post :create, params: params, as: :json

        response_body = JSON.parse(response.body)

        expect(response.status).to eq(409)
        expect(response_body['success']).to be_falsey
        expect(response_body['exception']).to eq(interview_slot_unavailable_error)
      end
    end

    context 'with available slot' do
      it 'books the slot and returns success message' do
        post :create, params: params, as: :json

        response_body = JSON.parse(response.body)
        new_interview = Interview.for_interview_slots(interview_slot.id).last

        expect(response.status).to eq(201)
        expect(response_body['success']).to be_truthy
        expect(response_body['data']).to eq(success_message)

        expect(interview_slot.reload.status).to eq('scheduled')

        expect(new_interview.status).to eq('scheduled')
        expect(new_interview.interviewee_id).to eq(student.id)
        expect(new_interview.grade).to be_nil
      end
    end
  end
end
