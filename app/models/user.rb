class User
  include DataMapper::Resource
  include DataMapper::Validate
  include Paperclip::Resource

  cattr_accessor :current_user
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  property :favorites_count, Integer, :index => true, :default => 0

  property :notes_count, Integer, :index => true, :default => 0

  # Primary key of the user
  property :id, Serial, :key => true, :index => true

  # Email of the user
  property :email, String, :required => true, :unique => true

  property :avatar_file_name, String

  property :avatar_content_type, String

  property :avatar_file_size, Integer

  property :avatar_updated_at, DateTime

  property :favorites_count, Integer, :index => true, :default => 0

  property :per_page_count, Integer, :index => true, :default => 25

  # Full name of the user
  property :name, String, :lazy => true, :lazy => true

  # The timezone the user lives in
  property :timezone, String, :default => 'UTC', :lazy => true

  # Define if the user has administrative privileges
  property :admin, Boolean, :default => false

  # Define created_at and updated_at timestamps
  timestamps :at

  has_attached_file :avatar,
  :styles => {
    :large => "500x500>",
    :medium => "300x300>",
    :small => "100x100#"
  }, :default_url => '/images/default_avatar.png', :processors => [:cropper]

  validates_attachment_content_type :avatar, :content_type => ["image/png", "image/gif", "image/jpeg"]

  has n, :favorites, :child_key => :user_id, :constraint => :destroy

  has n, :notes, :child_key => :user_id, :constraint => :destroy

  has n, :events, :through => :favorites

  #
  # Converts the user to a String.
  #
  # @return [String]
  #   The name of the user.
  #
  def to_s
    self.name.to_s
  end

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def avatar_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(avatar.path(style))
  end

  def reprocess_avatar
    avatar.reprocess! if cropping?
  end

end
