class GroupsController < ApplicationController
  include SocialStream::Controllers::Subjects

  before_filter :authenticate_user!, :except => [ :index, :show ]

  # Set group founder to current_subject
  # Must do before authorization
  before_filter :set_founder, :only => [ :new, :create ]

  load_and_authorize_resource

  respond_to :html, :js

  def index
    raise ActiveRecord::RecordNotFound
  end

  def create
    create! do |success, failure|
      success.html {
        self.current_subject = resource
        redirect_to :home
      }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html {
        self.current_subject = current_user
        redirect_to :home
      }
    end
  end

  protected

  # Overwrite resource method to support slug
  # See InheritedResources::BaseHelpers#resource
  def method_for_find
    :find_by_slug!
  end

  private

  def set_founder
    resource_params.first[:author_id]      ||= current_subject.try(:actor_id)
    resource_params.first[:user_author_id] ||= current_user.try(:actor_id)
  end
end
