WORKER_COUNT = 2
MEMORY_CONTROLLER = 4096
MEMORY_WORKER = 6144
CPU_CONTROLLER = 1
CPU_WORKER = 1

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
  
  # Worker nodes
  (1..WORKER_COUNT).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.hostname = "node-#{i}"
      node.vm.network "private_network", ip: "192.168.56.#{100+i}"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = MEMORY_WORKER
        vb.cpus = CPU_WORKER
      end
    end
  end
end