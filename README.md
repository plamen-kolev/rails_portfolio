# How to install and setup

1. Install system dependencies ```sudo apt-get install ruby-dev imagemagick libmagickwand-dev libmysqld-dev libsqlite3-dev nodejs -y
sudo gem install bundle```
1. Install rails dependencies `bundle install --path vendor`
1. Update bundle dependencies `bundle update`
1. Run rake task to initialize project and for it to do static compilation to `/plamen-kolev.github.io`
    * `DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=production bin/rake faker:init` should do the job for production
    * Ensure that `plamen-kolev.github.io` is a git repository and is pointing to the correct origin `git@github.com:plamen-kolev/plamen-kolev.github.io.git`

1. in `/media/images/creative/` you can drop images and the will be converted to html items and thumbnails
1. New articles can be written when the application boots by going to appurl/admin, but first `/bin/rails c` followed by `Admin.create(:email => 'admin@kolev.io', :password => 'password', :password_confirmation => 'password')` to create the admin user
    * they would have to be appended to the initializer task so they 'persist'
