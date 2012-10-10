Dummy::Application.routes.draw do
  #
  # session handlers
  #
  get     "els_session/new"

  get     "els_session/show"
  
  post    "els_session/create"

  delete  "els_session/destroy"
  
  root :to => 'els_session#show'
end
