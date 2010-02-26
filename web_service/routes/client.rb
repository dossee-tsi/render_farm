module RenderFarm

  get '/client' do
    client_area!
    client = Client.first(:email => @auth.credentials[0])
    content_type :json, :charset => 'utf-8'
    {
      :email => client.email,
      :created => client.created,
      :render_time => client.render_time,
      :tasks => client.tasks
    }.to_json
  end

  post '/client' do
    local_area!
    requires params, :render_time
    key = one_of params, :id, :email
    client = Client.first(key => params[key])
    updated = false
    if client
      client.render_time = params[:render_time]
      updated = client.save
    end
    if updated
      content_type :json, :charset => 'utf-8'
      {
        :id => client.id,
        :email => client.email,
        :created => client.created,
        :render_time => client.render_time
      }.to_json
    else
      throw_bad_request
    end
  end

end
