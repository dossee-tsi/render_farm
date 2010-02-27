module RenderFarm

  post '/register' do
    local_area!
    requires params, :email, :password
    client = Client.new({
      :email => params[:email],
      :password => Digest::SHA1.hexdigest(params[:password]),
      :created => Time.new,
      :render_time => 0,
      :tasks => []
    })
    if client.save
      json({ :id => client.id, :created => client.created })
    else
      throw_bad_request
    end
  end

end
