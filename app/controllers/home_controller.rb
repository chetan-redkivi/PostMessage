class HomeController < ApplicationController
  def index
    if user_signed_in?
      token,uid = initialise_objects()
      token  = "AAACGumRVIhYBABZCnmeqOcnPYtzgWXv489he6dvioSeHRFx7ugZCRfmZCSBYkV7ZBKZBL4tnUcnxChZCbNwFcBGYUoPcYqfKXsMROcJWcu4gZDZD"
      uid = "1685211760"
      @graph = Koala::Facebook::API.new("#{token}")

      friends_profile = @graph.get_connections("#{uid}","friends","fields" => "id,name,picture,link")
      fetch_sorted_friends_profile(friends_profile)

      fetch_groups = @graph.get_connections("#{uid}", "groups","fields" => "id,name,picture,link")
      fetch_sorted_groups(fetch_groups)

      fetch_pages = @graph.get_connections("#{uid}", "likes","fields" => "id,name,picture,link,category,can_post")
      fetch_sorted_pages(fetch_pages)
    end
  end

 def fetch_sorted_pages(fetch_pages)
   @pages = []
   if fetch_pages.present?
     fetch_pages.each do |page|
       if page["can_post"]
         pg = {}
         pg["id"] = page["id"]
         pg["name"] = page["name"]
         pg["link"] = page["link"]
         pg["picture"] = page["picture"]["data"]["url"]
         @pages << pg
       end
     end
     unless @pages.blank?
       @pages = @pages.sort_by { |hsh| hsh["name"] }
     end
   end
 end


 def fetch_sorted_groups(fetch_groups)
    @groups = []
    if fetch_groups.present?
      fetch_groups.each do |group|
        grp = {}
        grp["id"] = group["id"]
        grp["name"] = group["name"]
        if group["picture"]["is_silhouette"]
          @picture = group["picture"]["data"]["url"]
        else
          @picture = "default-group.png"
        end
        grp["link"] = group["link"]
        grp["picture"] = @picture
        @groups << grp
      end
      unless @groups.blank?
        @groups = @groups.sort_by { |hsh| hsh["name"] }
      end

    end
  end

  def fetch_sorted_friends_profile(friends_profile)
    @friends_profile = []
    if friends_profile.present?
      friends_profile.each do |friend|
        friend_profile = {}
        friend_profile["id"] = friend["id"]
        friend_profile["name"] = friend["name"]
        friend_profile["link"] = friend["link"]
        friend_profile["picture"] = friend["picture"]["data"]["url"]
        unless friend_profile.blank?
          @friends_profile << friend_profile
        end
      end
      unless @friends_profile.blank?
        @friends_profile = @friends_profile.sort_by { |hsh| hsh["name"] }
      end
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
