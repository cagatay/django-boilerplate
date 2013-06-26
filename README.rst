::

    $ django-admin.py startproject --template=django-boilerplate --name=.gitignore --extension=rst,pp,json {{ project_name }}

==================
Setup Environement
==================
* Install `VirtualBox <https://www.virtualbox.org/wiki/Downloads>`_
* Install `Vagrant <http://downloads.vagrantup.com>`_

::

    $ vagrant up
    $ vagrant ssh
    ({{project_name}})$ python manage.py runserver 0.0.0.0:8000

==================
Deploy to AWS
==================

::

    $ mv ebextensions .ebextensions
    $ eb init
    $ eb start
    $ git aws.push
