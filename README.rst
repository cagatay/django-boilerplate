==================
Setup Environement
==================
* Install `VirtualBox <https://www.virtualbox.org/wiki/Downloads>`_
* Install `Vagrant <http://downloads.vagrantup.com>`_
* You also need to install `PuTTY <http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html>`_ or another SSH client if you're on a Windows box.

::

    $ cd {{project_name}}
    $ vagrant up
    $ vagrant ssh
    ({{project_name}})$ python manage.py runserver 0.0.0.0:8000
