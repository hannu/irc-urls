module ActionView
  module Helpers
    module GoogleAssetTagHelper
      GOOGLE_PATHS = {
        'prototype' => 'ajax.googleapis.com/ajax/libs/prototype/1.6.0.3/prototype.js',
        'controls'  => 'ajax.googleapis.com/ajax/libs/scriptaculous/1.8.1/controls.js',
        'dragdrop'  => 'ajax.googleapis.com/ajax/libs/scriptaculous/1.8.1/dragdrop.js',
        'effects'   => 'ajax.googleapis.com/ajax/libs/scriptaculous/1.8.1/effects.js',
        'jquery'    => 'ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js',
        'jquery-ui' => 'ajax.googleapis.com/ajax/libs/jqueryui/1.8.3/jquery-ui.min.js'
      }

      def self.included(base)
        base.send :alias_method_chain, :expand_javascript_sources, :google unless Rails.application.config.consider_all_requests_local
      end

      def expand_javascript_sources_with_google(sources, recursive = false)
        protocol = request.ssl? ? "https://" : "http://"
        google_sources, normal_sources = sources.partition { |source| GOOGLE_PATHS.include? source.to_s }
        GOOGLE_PATHS.values_at(*google_sources).map { |url| protocol + url } + expand_javascript_sources_without_google(normal_sources, recursive)
      end
    end
  end
end

ActionView::Base.class_eval do
  include ActionView::Helpers::GoogleAssetTagHelper
end
