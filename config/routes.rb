Rails.application.routes.draw do
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :interview_slots, only: [:index, :create]
    end
  end
end
