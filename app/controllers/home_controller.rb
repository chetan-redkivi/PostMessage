class HomeController < ApplicationController
  def index
    if user_signed_in?
      token,uid = initialise_objects()
      @graph = Koala::Facebook::API.new("#{token}")
      @friends = @graph.get_connections("#{uid}","friends")
      @groups = @graph.get_connections("#{uid}", "groups")
      @pages = @graph.get_connections("#{uid}", "likes")
    end
  end

  def post_on_page
    all_ids = []
    if params["pageId"].present?
      all_ids = all_ids + params["pageId"]
    end

    if params["groupId"].present?
      all_ids = all_ids + params["groupId"]
    end

    if params["friendId"].present?
      all_ids = all_ids + params["friendId"]
    end

    if all_ids.present?
      token,uid = initialise_objects()
      @graph = Koala::Facebook::API.new("#{token}")
      all_ids.each do |id|
        @graph.put_connections("#{id}", "feed", :message => params["message"])
      end
    end

    redirect_to root_url
  end




  def initialise_objects
    uid   = current_user.fb_authentication.uid
    token = current_user.fb_authentication.token
    return token,uid
  end



end
