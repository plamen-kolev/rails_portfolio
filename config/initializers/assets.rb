# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'
Rails.application.config.assets.precompile += %w( styles/github-gist.min.css styles/asciidoctor.css photoswipe/photoswipe.min.js photoswipe/photoswipe-ui-default.min.js photoswipe/photoswipe.css photoswipe/default-skin/default-skin.css print.css)
# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
