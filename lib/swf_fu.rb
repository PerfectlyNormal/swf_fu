require "rails"

module SwfFu
  autoload :Generator, 'swf_fu/generator'
  autoload :SwfAsset,  'swf_fu/swf_asset'

  DEFAULTS = {
    :width            => "100%",
    :height           => "100%",
    :flash_version    => 7,
    :mode             => :dynamic,
    :auto_install     => "expressInstall",
    :alt    => <<-"EOS".squeeze(" ").strip.freeze
      <a href="http://www.adobe.com/go/getflashplayer">
        <img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" />
      </a>
    EOS
  }.freeze
  DIRECTORY = 'assets'.freeze
  EXTENSION = 'swf'.freeze

  class Engine < Rails::Engine
    config.to_prepare do
      ActionView::Base.class_eval do
        cattr_accessor :swf_default_options
      end
      ActionView::Base.swf_default_options = {}
    end
  end
end