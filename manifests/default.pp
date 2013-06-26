# variables
$user = "vagrant"
$group = "$user"
$project_name = "{{ project_name }}"
$user_home = "/home/$user"
$project_home = "/vagrant"
$virtualenvs = "$user_home/.virtualenvs"
$project_virtualenv = "$virtualenvs/$project_name"

# other packages to install
$packages = [
  "git",
  "build-essential",
  "pkg-config",
  "vim",
  "libmysqlclient-dev",
]

# Define exec path
Exec {
  path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

# appends line to file
define line($file, $line, $ensure = 'present') {
  case $ensure {
    default : { err ( "unknown ensure value ${ensure}" ) }
    present: {
      exec { "/bin/echo '${line}' >> '${file}'":
        unless => "/bin/grep -qFx '${line}' '${file}'"
      }
    }
    absent: {
      exec { "/bin/grep -vFx '${line}' '${file}' | /usr/bin/tee '${file}' > /dev/null 2>&1":
        onlyif => "/bin/grep -qFx '${line}' '${file}'"
      }
    }
  }
}

# run apt-get update before package operations
exec { "apt-update":
    command => "/usr/bin/apt-get update"
}

Exec["apt-update"] -> Package <| |>

# install python and utils
class { 'python':
  dev        => true,
  virtualenv => true,
  pip        => true,
}

# install mysql server
class { 'mysql::server':
  config_hash => { 'root_password' => '' },
}

# create db
mysql::db { "$project_name":
  user     => 'dev',
  password => 'dev',
}

# install system packages
package { $packages:
  ensure => "installed",
  before => Mysql::Db[$project_name],
}

# create virtual environment
python::virtualenv { $project_virtualenv:
  ensure       => present,
  requirements => "$project_home/requirements.txt",
  distribute   => true,
  owner        => $user,
  group        => $group,
  require      => Mysql::Db["$project_name"],
}

# run activate script on login
line { "venv-activate":
  file => "$user_home/.bashrc",
  line => "cd $project_home; . $project_virtualenv/bin/activate",
  ensure => present,
}

# run syncdb
exec { "syncdb":
  command => "$project_virtualenv/bin/python $project_home/manage.py syncdb --noinput",
  user => "vagrant",
  require => Python::Virtualenv[$project_virtualenv],
}
