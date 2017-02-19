$rails_app = '/var/www/rails_portfolio'

exec {"/usr/bin/yum":
  command => '/usr/bin//usr/bin/yum'
}

package {'libmagickwand-dev':
  ensure => present,
  require => Exec["/usr/bin/yum"],
}

package { "imagemagick":
  ensure  => present,
  require => Exec["/usr/bin/yum"],
}

package {'build-essential':
  ensure => present,
  require => Exec['/usr/bin/yum']
}

package {'zlib1g-dev':
  ensure => present,
    require => Exec["/usr/bin/yum"],
}

package { "ruby":
  ensure => present,

  require => [Package['build-essential'], Exec["/usr/bin/yum"]]
}

package { "ruby-dev":
  ensure => present,
  require => Exec["/usr/bin/yum"]
}

package { "rails":
  ensure => present,
  require => [Package['ruby'], Package['ruby-dev'], Package['bundle'], Package['unicorn']]
}

package {'libmysqld-dev':
  ensure => present,
  require => Exec["/usr/bin/yum"],
}

package { "nginx":
  ensure  => present,
  require => Exec["/usr/bin/yum"],
}

package { "libsqlite3-dev":
  ensure  => present,
  require => Exec["/usr/bin/yum"],
}

# gems
package { "bundle":
  ensure => 'installed',
  provider => 'gem',
  require => [Package['ruby'], Package['ruby-dev'], Package['zlib1g-dev']]
}

package { "unicorn":
  ensure => 'installed',
  provider => 'gem',
  require => [Package['ruby'], Package['ruby-dev']]
}

exec { "setup portfolio database":
  # command => '/bin/echo -e "\ny\ny\npassword\npassword\ny\ny\ny\ny" | /usr/bin/mysql_secure_installation'
  command => "/usr/bin/mysql -u root -ppineapples -e \"CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password'; CREATE DATABASE rails_portfolio ; GRANT ALL PRIVILEGES ON rails_portfolio.* TO 'admin'@'localhost'; \"",
  returns => [0,1],
  require => Class['::mysql::server']
}

exec { "puppet-mysql":
  command => "/usr/bin/puppet module install puppetlabs-mysql"
}

class { '::mysql::server':
  root_password           => 'pineapples',
  remove_default_accounts => true,
  require => Exec["puppet-mysql"],
}

file { $rails_app :
  ensure    => directory,
  owner     => 'www-data',
  group      => 'www-data',
  recurse    => true
}

vcsrepo { $rails_app:
  ensure   => present,
  provider => git,
  source   => 'https://github.com/plamen-kolev/rails_portfolio.git',
}

exec {'install rails dependencies':
  command => '/usr/bin/bundle install --without development',
  environment => ["RAILS_ENV=production"],
  user        => "root",
  cwd => $rails_app,
  require => [Package['imagemagick'], Package['libmagickwand-dev'], Package['libmysqld-dev'], Vcsrepo[$rails_app], Package['libsqlite3-dev']]
}

exec {'setup production database':
  command => "/usr/bin/mysql -u root -ppineapples -e \"CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password'; CREATE DATABASE rails_portfolio ; GRANT ALL PRIVILEGES ON rails_portfolio.* TO 'admin'@'localhost'; \"",
  returns => [0,1],
  require => [Class['::mysql::server'], Exec['install rails dependencies']]
}

exec {'migrate production database':
  command => '/usr/bin/rake db:migrate',
  user        => "www-data",
  environment => ["RAILS_ENV=production"],
  cwd => $rails_app,
  require => [Exec['setup production database'], File[$rails_app]]
}

exec {'compile static assets':
  command => '/usr/bin/rails assets:precompile',
  user        => "www-data",
  environment => ["RAILS_ENV=production"],
  cwd => $rails_app,
  require => [Exec['install rails dependencies'], File[$rails_app]]
}

exec {'push content to production database':
  command => '/usr/bin/rake faker:init',
  user        => "www-data",
  environment => ["RAILS_ENV=production", "DISABLE_DATABASE_ENVIRONMENT_CHECK=1"],
  cwd => $rails_app,
  require => [Vcsrepo[$rails_app], Exec['migrate production database'], Exec['install rails dependencies']]
}

exec {'run unicorn production server':
  command => '/usr/bin/bundle exec unicorn -D',
  returns => [1,0],
  user        => "www-data",
  environment => ["RAILS_ENV=production"],
  cwd => $rails_app,
  require => [Exec['install rails dependencies'], File[$rails_app], Exec['push content to production database']]
}

exec {'copy static files to shared folder':
  command => '/bin/cp -r /var/www/rails_portfolio/plamen-kolev.github.io/ /vagrant/static/',
  user => 'root',
  require => Exec['push content to production database']
}

exec {'copy project files to shared folder':
  command => '/bin/cp -r /var/www/rails_portfolio /vagrant/',
  user => 'root',
  require => Exec['push content to production database']
}

exec {'copy project config to nginx':
  command => "/bin/cp $rails_app/dynamic_portfolio.conf /etc/nginx/sites-available/",
  require => [Package['nginx'], Vcsrepo[$rails_app]]
}

exec {'link site-available conf to site-enabled':
  command => '/bin/ln -s /etc/nginx/sites-available/dynamic_portfolio.conf /etc/nginx/sites-enabled/dynamic_portfolio.conf',
  returns => [1,0],
  require => Exec['copy project config to nginx']
}

exec {'force restart nginx after configuration':
  command => '/usr/bin/sudo service nginx restart',
  user => 'root',
  require => Exec['link site-available conf to site-enabled']
}

