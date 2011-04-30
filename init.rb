require 'actionview_helpers_patches'
require 'asset_tag_helper_patch'
require 'tag_helper_patches'
require 'prototype_helper_patch'
require 'javascript_helper_patch'
require 'oh_behave'

# Adding path to behaviours controller
config.load_paths += %W(#{OhBehave::PLUGIN_CONTROLLER_PATH})
Rails::Initializer.run(:set_load_path, config)

# helpers are used to make sure view can transport behaviours to controller
ActionController::Base.send(:helper, OhBehave::Helpers)

# including methods to generate and store behaviours in session
ActionController::Base.send(:include, OhBehave::ControllerMethods)

# caching - quite obvious I think
ActionController::Base.send(:include, OhBehave::BehaviourCaching)

# behaviours controller
require 'behaviours_controller'
