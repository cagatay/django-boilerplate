$system = [
  "python-dev",
  "python-pip",
  "mysql-server",
  "libmysqlclient-dev",
  "git",
  "build-essential",
  "pkg-config",
]

$pypi = [
  "virtualenv",
  "virtualenvwrapper",
]

$user_home = "/home/vagrant"
$workon_home = "$user_home/.virtualenvs"
$project_name = "{{project_name}}"
$project_home = "/vagrant"
$project_venv = "$workon_home/$project_name"
$virtualenvwrapper_script = "/usr/local/bin/virtualenvwrapper.sh"
$create_db_sql = "CREATE DATABASE IF NOT EXISTS $project_name CHARACTER SET utf8 COLLATE utf8_general_ci"

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

      # Use this resource instead if your platform's grep doesn't support -vFx;
      # note that this command has been known to have problems with lines containing quotes.
      # exec { "/usr/bin/perl -ni -e 'print unless /^\\Q${line}\\E\$/' '${file}'":
      #     onlyif => "/bin/grep -qFx '${line}' '${file}'"
      # }
    }
  }
}

package { $system:
  ensure => "installed",
}

package { $pypi:
  provider => pip,
  ensure => "installed",
}

exec { "create-venv":
  command => "/bin/bash -c \"export WORKON_HOME=$workon_home; . $virtualenvwrapper_script; mkvirtualenv $project_name\"",
  creates => "$workon_home/$project_name",
  user => "vagrant",
  require => Package[$pypi],
  logoutput => true,
}

line { "install-venvwrapper":
  file => "$user_home/.bashrc",
  line => ". $virtualenvwrapper_script; workon $project_name; cd $project_home",
  ensure => present,
}

exec { "install-requirements":
  command => "$project_venv/bin/pip install -vr $project_home/requirements.txt",
  user => "vagrant",
  require => Exec["create-venv"],
  timeout => 0,
  logoutput => true,
}

exec { "create-db":
  command => "/bin/bash -c \"echo '$create_db_sql' | mysql -u root\"",
  user => "vagrant",
  require => Package["mysql-server"],
  logoutput => true,
}

exec { "syncdb":
  command => "$project_venv/bin/python $project_home/manage.py syncdb --noinput",
  user => "vagrant",
  require => Exec["install-requirements"],
  logoutput => true,
}
