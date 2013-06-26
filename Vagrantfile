# vim: set ft=ruby

Vagrant.configure("2") do |config|
    config.vm.box = "precise64"
    config.vm.box_url = "http://files.vagrantup.com/precise64.box"
    config.vm.hostname = "vagrant.local"
    config.vm.network :forwarded_port, host: 8000, guest: 8000
    config.vm.provision :puppet do |puppet|
      puppet.module_path = "manifests/modules"
      #puppet.options = "--verbose --debug"
    end
end
