require 'rails_helper'

RSpec.describe 'Tasks API' do
  before { host! 'api.taskmanager.dev' }
  let(:user) { create(:user) }
  let(:headers) do
    {
        'Content-Type' => Mime[:json].to_s,
     'Accept' => 'application/vnd.taskmanager.v1',
     'Authorization' => user.auth_token
    }
  end
  describe 'GET /tasks' do
    before do
      create_list(:task, 5, user_id: user.id)
      get '/tasks', params: {}, headers: headers
    end
    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
    it 'returns 5 tasks from database' do
      expect(json_body[:tasks].count).to eq(5)
    end
  end
  describe 'GET /tasks/:id' do
    let(:task) { create(:task, user_id: user.id) }
    before { get "/tasks/#{task.id}", params: {}, headers: headers }

    it 'should return status code 200' do
      expect(response).to have_http_status(200)
    end
    it 'should returns the jason for tasks' do
      expect(json_body[:title]).to eq(task.title)
    end
  end
  describe 'POST /tasks' do
    before do
      post '/tasks', params: { task: task_params}.to_json , headers: headers
    end
    
    context 'when params are valid' do
      let(:task_params) { attributes_for(:task) }

      it 'should return the satus code 201' do
        expect(response).to have_http_status(201)
      end
      it 'should save the task in the database' do
        expect(Task.find_by(title: task_params[:title])).not_to be_nil
      end
      it 'should returns the json for created task' do
        expect(json_body[:title]).to eq(task_params[:title])
      end
      it 'should assign the created task for the current user' do
        expect(json_body[:user_id]).to eq(user.id)
      end

    end

    context 'when params are invalida' do
      let(:task_params) { attributes_for(:task, title: ' ') }
      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
      it 'should not save the taks in the database' do
        expect(Task.find_by(title: task_params[:title])).to be_nil
      end
      it 'should return the json error for title' do
        expect(json_body[:errors]).to have_key(:title)
      end
    end
  end
  describe 'PUT /tasks/:id' do
    let(:task) { create(:task, user_id: user.id) }
    before do
      put "/tasks/#{task.id}", params: { task: task_params }.to_json, headers: headers
    end
    context 'when the params are valid' do
      let(:task_params) {{ title: "New task title" }}
      it 'should return the status code 200' do
        expect(response).to have_http_status(200)
      end
      it 'should return the json for updated task' do
        expect(json_body[:title]).to eq(task_params[:title])
      end
      it 'should update the task in database' do
        expect(Task.find_by(title: task_params[:title])).not_to be_nil
      end
    end
    context 'when the params are invalid' do
      let(:task_params) {{ title: ' '}}
      it 'should returns status code 422' do
        expect(response).to have_http_status(422)
      end
      it 'should return the json error for title' do
        expect(json_body[:errors]).to have_key(:title)
      end
      it 'should not update the task in database' do
        expect(Task.find_by(title: task_params[:title])).to be_nil
      end

    end
  end
  describe 'DELETE /tasks/:id' do
    let(:task) { create(:task, user_id: user.id) }
    before do
      delete "/tasks/#{task.id}", params: {}, headers: headers
    end
    it 'should return the status code 204' do
      expect(response).to have_http_status(204)
    end
    it 'should remove the task from the database' do
      expect{ Task.find(task.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end