  WORKER_COUNT = 1        # Number of workers within cluster
  MEMORY_CONTROLLER = 10240 # 4096 # Controller memory (MB)
  MEMORY_WORKER = 10240 # 6144     # Workers memory (MB for each worker)
  CPU_CONTROLLER = 4 # 2       # Controller CPU cores
  CPU_WORKER = 4 # 2           # Worker CPU cores (each)

  Vagrant.configure("2") do |config|
    config.vm.box = "bento/ubuntu-24.04"
    
    # Controller node - set it as primary to ensure it's created first
    config.vm.define "ctrl", primary: true do |ctrl|
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

    # Create common Ansible groups and vars that will be used for all provisioners
    ansible_groups = {
      "controller" => ["ctrl"],
      "worker" => (1..WORKER_COUNT).map { |j| "node-#{j}" },
      "all:children" => ["controller", "worker"]
    }
    
    ansible_vars = {
      worker_count: WORKER_COUNT,
      memory_controller: MEMORY_CONTROLLER,
      memory_worker: MEMORY_WORKER,
      cpu_controller: CPU_CONTROLLER,
      cpu_worker: CPU_WORKER
    }
    
    # First setup the controller node - only on ctrl
    config.vm.define "ctrl" do |ctrl|
      ctrl.vm.provision "ansible" do |ansible|
        ansible.playbook = "ansible/setup-controller.yaml"
        ansible.groups = ansible_groups
        ansible.extra_vars = ansible_vars
      end
    end
    
    # Finally setup the worker nodes - only on worker nodes
    (1..WORKER_COUNT).each do |i|
      config.vm.define "node-#{i}" do |node|
        node.vm.provision "ansible" do |ansible|
          ansible.playbook = "ansible/setup-workers.yaml"
          ansible.groups = ansible_groups
          ansible.extra_vars = ansible_vars
        end
      end
    end
  end
  # Vagrant.configure("2") do |config|
  #   config.vm.box = "bento/ubuntu-24.04"
  #   # Controller node
  #   config.vm.define "ctrl" do |ctrl|
  #     ctrl.vm.hostname = "ctrl"
  #     ctrl.vm.network "private_network", ip: "192.168.56.100"
  #     ctrl.vm.provider "virtualbox" do |vb|
  #       vb.memory = MEMORY_CONTROLLER
  #       vb.cpus = CPU_CONTROLLER
  #     end

  #     # Single ansible_local provisioner that runs both playbooks
  #     ctrl.vm.provision "ansible_local" do |ansible|
  #       ansible.playbook = "ansible/setup-controller.yaml"
  #       ansible.groups = {
  #         "controller" => ["ctrl"],
  #         "worker" => (1..WORKER_COUNT).map { |j| "node-#{j}" },
  #         "all:children" => ["controller", "worker"]
  #       }

  #       ansible.extra_vars = {
  #         worker_count: WORKER_COUNT,
  #         memory_controller: MEMORY_CONTROLLER,
  #         memory_worker: MEMORY_WORKER,
  #         cpu_controller: CPU_CONTROLLER,
  #         cpu_worker: CPU_WORKER
  #       }
  #     end
  #   end
    
  #   # Worker nodes
  #   (1..WORKER_COUNT).each do |i|
  #     config.vm.define "node-#{i}" do |node|
  #       node.vm.hostname = "node-#{i}"
  #       node.vm.network "private_network", ip: "192.168.56.#{100+i}"
  #       node.vm.provider "virtualbox" do |vb|
  #         vb.memory = MEMORY_WORKER
  #         vb.cpus = CPU_WORKER
  #       end
  #     end
  #   end

  #   # Provisioning for all nodes (controller and workers), this will be run after each of ctrl and node-j started, but will not take effect for already applied ones
  #   config.vm.provision "ansible" do |ansible|
  #     ansible.playbook = "ansible/all-nodes-setup.yaml"
  #     ansible.groups = {
  #       "controller" => ["ctrl"],
  #       "worker" => (1..WORKER_COUNT).map { |j| "node-#{j}" },
  #       "all:children" => ["controller", "worker"]
  #     }
      
  #     ansible.extra_vars = {
  #       worker_count: WORKER_COUNT,
  #       memory_controller: MEMORY_CONTROLLER,
  #       memory_worker: MEMORY_WORKER,
  #       cpu_controller: CPU_CONTROLLER,
  #       cpu_worker: CPU_WORKER
  #     }
  #     ansible.limit = "all" # Ensures the playbook applies to all nodes
  #   end

  #   #     # Executes Ansible after the configuration of last node
  #   #     # if i == WORKER_COUNT
  #   #       node.vm.provision "ansible" do |ansible|
  #   #         ansible.playbook = "ansible/general.yaml"
            
  #   #         ansible.groups = {
  #   #           "controller" => ["ctrl"],
  #   #           "worker" => (1..WORKER_COUNT).map { |j| "node-#{j}" },
  #   #           "all:children" => ["controller", "worker"]
  #   #         }
            
  #   #         ansible.extra_vars = {
  #   #           worker_count: WORKER_COUNT,
  #   #           memory_controller: MEMORY_CONTROLLER,
  #   #           memory_worker: MEMORY_WORKER,
  #   #           cpu_controller: CPU_CONTROLLER,
  #   #           cpu_worker: CPU_WORKER
  #   #         }
  #   #       end
  #   #         # ansible.limit = "all"

  #   #       # Run node.yaml specifically for worker nodes
  #   #       node.vm.provision "ansible_local" do |ansible|
  #   #         ansible.playbook = "ansible/node.yaml"
  #   #         ansible.groups = {
  #   #           "controller" => ["ctrl"],
  #   #           "worker" => (1..WORKER_COUNT).map { |j| "node-#{j}" },
  #   #           "all:children" => ["controller", "worker"]
  #   #         }

  #   #         ansible.extra_vars = {
  #   #           worker_count: WORKER_COUNT,
  #   #           memory_controller: MEMORY_CONTROLLER,
  #   #           memory_worker: MEMORY_WORKER,
  #   #           cpu_controller: CPU_CONTROLLER,
  #   #           cpu_worker: CPU_WORKER
  #   #         }
  #   #       end

  #   #     # end
  #   #   end
  #   # end
  # end
