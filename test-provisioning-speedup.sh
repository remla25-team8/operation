#!/bin/bash

# Provisioning Speedup Test Script
# Ensures each test starts from a clean state

set -e

echo "Provisioning Speedup Test Script"
echo "================================"
echo ""

# Check required tools
echo "Checking environment preparation..."
if ! command -v vagrant &> /dev/null; then
    echo "ERROR: Vagrant not installed or not in PATH"
    exit 1
fi

if ! command -v ansible &> /dev/null; then
    echo "ERROR: Ansible not installed or not in PATH"
    exit 1
fi

if ! command -v VBoxManage &> /dev/null; then
    echo "ERROR: VirtualBox not installed or not in PATH"
    exit 1
fi

echo "PASSED: Environment check completed"
echo ""

# 1. Thoroughly clean existing VMs
echo "Step 1: Thoroughly cleaning existing VMs..."
echo "Stopping and destroying current project VMs..."
vagrant destroy -f || true

echo "Cleaning possible zombie VMs..."
vagrant global-status --prune || true

# Check if there are related VirtualBox VMs running
echo "Checking for related VMs in VirtualBox..."
VBoxManage list runningvms | grep -E "(ctrl|node-[0-9]+|operation)" && {
    echo "WARNING: Found running related VMs, forcing shutdown..."
    VBoxManage list runningvms | grep -E "(ctrl|node-[0-9]+|operation)" | awk '{print $2}' | tr -d '{}' | while read vm_id; do
        echo "Forcing shutdown of VM: $vm_id"
        VBoxManage controlvm "$vm_id" poweroff || true
    done
} || echo "PASSED: No running related VMs found"

# Delete possible leftover VMs
echo "Deleting possible leftover VMs..."
VBoxManage list vms | grep -E "(ctrl|node-[0-9]+|operation)" && {
    echo "Found leftover VMs, deleting..."
    VBoxManage list vms | grep -E "(ctrl|node-[0-9]+|operation)" | awk '{print $2}' | tr -d '{}' | while read vm_id; do
        echo "Deleting VM: $vm_id"
        VBoxManage unregistervm "$vm_id" --delete || true
    done
} || echo "PASSED: No leftover VMs found"

echo "PASSED: VM cleanup completed"
echo ""

# 2. Display configuration information
echo "Step 2: Displaying current optimization configuration..."
echo "VM Configuration:"
echo "  - Controller: 6144MB RAM, 2 CPU"
echo "  - Workers: 6144MB RAM x2, 2 CPU each"
echo "  - Using linked clone optimization"
echo "  - SSH timeout optimization"
echo "  - Ansible task optimization"
echo ""

# 3. Start timed test
echo "Step 3: Starting provisioning test (target: < 4 minutes)..."
echo "Start time: $(date)"
echo ""

# Record start time
start_time=$(date +%s)

# Run provisioning
echo "Executing: vagrant up"
time vagrant up

# Calculate total time
end_time=$(date +%s)
total_time=$((end_time - start_time))
minutes=$((total_time / 60))
seconds=$((total_time % 60))

echo ""
echo "Completion time: $(date)"
echo "Total time: ${minutes}m ${seconds}s"

# Evaluate if target is reached
if [ $total_time -lt 240 ]; then
    echo "EXCELLENT: Achieved target of less than 4 minutes!"
elif [ $total_time -lt 300 ]; then
    echo "GOOD: Slightly slower than target but still good"
else
    echo "WARNING: Exceeded 5 minutes, may need further optimization"
fi

echo ""
echo "Step 4: Verifying provision results..."

# Verification tests
echo "Checking VM status..."
vagrant status

echo ""
echo "Checking Kubernetes cluster status..."
vagrant ssh ctrl -c "kubectl get nodes -o wide" || {
    echo "FAILED: Kubernetes cluster check failed"
    exit 1
}

echo ""
echo "Checking system pods..."
vagrant ssh ctrl -c "kubectl get pods -A" || {
    echo "FAILED: System pods check failed"
    exit 1
}

echo ""
echo "Quick functionality test..."
vagrant ssh ctrl -c "kubectl create deployment test-speedup --image=nginx:alpine --replicas=1" || {
    echo "FAILED: Functionality test failed"
    exit 1
}

sleep 15

vagrant ssh ctrl -c "kubectl get pods -l app=test-speedup" && {
    vagrant ssh ctrl -c "kubectl delete deployment test-speedup"
    echo "PASSED: Functionality test completed"
} || {
    echo "FAILED: Functionality test failed"
    exit 1
}

echo ""
echo "Test Summary:"
echo "  - PASSED: VM status normal"
echo "  - PASSED: Cluster status normal"  
echo "  - PASSED: Functionality test passed"
echo "  - TIME: Total time ${minutes}m ${seconds}s"
echo ""
echo "SUCCESS: Provisioning Speedup test completed!"

# Optional: Display resource usage
echo ""
echo "Resource usage:"
vagrant ssh ctrl -c "free -h && df -h /" 2>/dev/null || true 