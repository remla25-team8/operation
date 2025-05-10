WORKER_COUNT = 2        # Numero di worker nodes nel cluster
MEMORY_CONTROLLER = 1024#4096 # Memoria in MB per il nodo controller
MEMORY_WORKER = 1024#6144     # Memoria in MB per ciascun worker node
CPU_CONTROLLER = 1       # CPU cores per il nodo controller
CPU_WORKER = 1           # CPU cores per ciascun worker node

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
      
      # Executes Ansible after the configuration of last node
      if i == WORKER_COUNT
        node.vm.provision "ansible" do |ansible|
          ansible.playbook = "ansible/general.yaml"
          
          ansible.groups = {
            "controller" => ["ctrl"],
            "worker" => (1..WORKER_COUNT).map { |j| "node-#{j}" },
            "all:children" => ["controller", "worker"]
          }
          
          ansible.extra_vars = {
            worker_count: WORKER_COUNT,
            memory_controller: MEMORY_CONTROLLER,
            memory_worker: MEMORY_WORKER,
            cpu_controller: CPU_CONTROLLER,
            cpu_worker: CPU_WORKER
          }
          
          ansible.limit = "all"
        end
      end
    end
  end
end