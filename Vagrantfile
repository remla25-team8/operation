  WORKER_COUNT = 2         # Number of workers within cluster
  MEMORY_CONTROLLER = 6144 # Controller memory (MB)
  MEMORY_WORKER = 6144     # Workers memory (MB for each worker)
  CPU_CONTROLLER = 2       # Controller CPU cores
  CPU_WORKER = 2           # Worker CPU cores (each)

  Vagrant.configure("2") do |config|
    config.vm.box = "bento/ubuntu-24.04"
    config.ssh.insert_key = false
    
    # SSH timeout configurations to prevent connection issues
    config.vm.boot_timeout = 600
    config.ssh.connect_timeout = 60
    config.ssh.forward_agent = true
    config.ssh.compression = true
    config.ssh.keep_alive = true
    config.ssh.keys_only = true

    # Sync host's ./shared folder to /shared in all VMs
    config.vm.synced_folder "./shared", "/mnt/shared"
    
    # Controller node - set it as primary to ensure it's created first
    config.vm.define "ctrl" do |ctrl|
      ctrl.vm.hostname = "ctrl"
      ctrl.vm.network "private_network", ip: "192.168.56.100"
      ctrl.vm.provider "virtualbox" do |vb|
        vb.memory = MEMORY_CONTROLLER
        vb.cpus = CPU_CONTROLLER
        vb.linked_clone = true
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
          vb.linked_clone = true
        end
      end
    end

    # Create Ansible groups and vars
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
    
    # Single provisioner that runs after all machines are created
    # This will execute our main playbook that handles all the steps in sequence
    config.vm.provision :ansible do |ansible|
      ansible.playbook = "ansible/main-playbook.yaml"
      ansible.groups = ansible_groups
      ansible.extra_vars = ansible_vars
      ansible.limit = "all"
    end
  end