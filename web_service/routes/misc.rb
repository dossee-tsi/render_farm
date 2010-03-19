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
    throw_bad_request unless client.save
    json({
      :id => client.id,
      :created => client.created
    })
  end
  
  get '/cluster' do
    local_area!
    json({ :ips => options.cluster_ips })
  end

end
