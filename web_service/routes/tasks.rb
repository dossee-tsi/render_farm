module RenderFarm

  post '/tasks' do
    client_area!
    # upload
  end

  get '/tasks/:id' do
    local_area!
    # status, xml, blend, output
  end

  post '/tasks/:id' do
    local_area!
    # accept, reject
  end

end
