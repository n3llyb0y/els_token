Dummy::Application.routes.draw do
  #
  # session handlers
  #
  get     "els_session/new"

  post    "els_session/create"

  delete  "els_session/destroy"
  
  root :to => 'els_session#show'
end
