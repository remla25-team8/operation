#!/bin/bash

# SSH Timeout Fix Test Script

set -e

echo "SSH Timeout Fix Test"
echo "===================="
echo ""

# Clean existing environment
echo "Cleaning existing VMs..."
vagrant destroy -f || true

echo ""
echo "Starting VMs to test SSH connections..."
echo "Start time: $(date)"

# Start VMs only, no provision
vagrant up --no-provision

echo ""
echo "Testing SSH connection stability..."

# Test SSH connections
for i in {1..5}; do
    echo "SSH connection test ${i}..."
    
    echo "  Testing ctrl node..."
    vagrant ssh ctrl -c "echo 'SSH to ctrl: OK'; hostname; uptime" || {
        echo "FAILED: ctrl node SSH connection failed"
        exit 1
    }
    
    echo "  Testing node-1..."
    vagrant ssh node-1 -c "echo 'SSH to node-1: OK'; hostname; uptime" || {
        echo "FAILED: node-1 SSH connection failed"
        exit 1
    }
    
    echo "  Testing node-2..."
    vagrant ssh node-2 -c "echo 'SSH to node-2: OK'; hostname; uptime" || {
        echo "FAILED: node-2 SSH connection failed"
        exit 1
    }
    
    echo "  PASSED: Test ${i} completed"
    echo ""
    
    # Wait 2 seconds before next test
    sleep 2
done

echo "SUCCESS: SSH connection stability test passed!"
echo ""

echo "Running complete provision test..."
start_time=$(date +%s)

vagrant provision

end_time=$(date +%s)
total_time=$((end_time - start_time))
minutes=$((total_time / 60))
seconds=$((total_time % 60))

echo ""
echo "Provision time: ${minutes}m ${seconds}s"

echo ""
echo "Final verification..."
vagrant ssh ctrl -c "kubectl get nodes" || {
    echo "FAILED: Final verification failed"
    exit 1
}

echo ""
echo "SUCCESS: SSH Timeout fix verification completed!"
echo "  - SSH connections stable"
echo "  - Provision successful"
echo "  - Cluster running normally" 