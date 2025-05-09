# Vagrantfile (initial)
MEMORY_CONTROLLER = 4096
CPU_CONTROLLER = 1

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"
  
  # Controller node
  config.vm.define "ctrl" do |ctrl|
    ctrl.vm.hostname = "ctrl"
    ctrl.vm.network "private_network", ip: "192.168.56.100"
    ctrl.vm.provider "virtualbox" do |vb|
      vb.memory = MEMORY_CONTROLLER
      vb.cpus = CPU_CONTROLLER
    end
  end
end