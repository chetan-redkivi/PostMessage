class HomeController < ApplicationController
  def index
    if user_signed_in?
      token,uid = initialise_objects()
      @graph = Koala::Facebook::API.new("#{token}")
      @friends = @graph.get_connections("#{uid}","friends","fields" => "id,name,picture,link")
      @groups = @graph.get_connections("#{uid}", "groups","fields" => "id,name,picture,link")
      @pages = @graph.get_connections("#{uid}", "likes","fields" => "id,name,picture,link")

    end
  end

  def post_on_page
    all_ids = []
    begin
      if params["message"].present?
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
        flash[:notice] = "Message has been posted successfully."
      else
        flash[:error] = "Message should not be blank"
      end
    rescue Exception => e
      Rails.logger.info("=========================#{e.message}")
      flash[:error] = e.message
    end
    redirect_to root_url
  end




  def initialise_objects
    uid   = current_user.fb_authentication.uid
    token = current_user.fb_authentication.token
    return token,uid
  end



end
