## Reproduce my errors in terminals
1. `vagrant up` stuck at step: Verify kube-apiserver is running on port 6443 
2. checking what happened inside the vm:
- `vagrant ssh ctrl` # login to the ctrl
- `sudo ss -tuln | grep 6443` # check the kube-apiserver, not running correctly
- `sudo crictl ps 2>/dev/null | grep kube-apiserver` # check the kube-apiserver, not running correctly
> Error 1: the kube-apiserver is not started as expected even the step 13 is passed
3. manually start the kube-apiserver inside ctrl
- first do this to reset
```
sudo kubeadm reset -f
sudo rm -rf /etc/cni/net.d
sudo systemctl restart kubelet
```
- `sudo kubeadm init --apiserver-advertise-address=192.168.56.100 --pod-network-cidr=10.244.0.0/16`
- `sudo ss -tuln | grep 6443` # check again, good
- `sudo crictl ps 2>/dev/null | grep kube-apiserver` # check again, good
4. manually get the command in ctrl for worker node join:
- `kubeadm token create --print-join-command` This gives error like
failed to create or update bootstrap token with name bootstrap-token-5xdqd1: unable to create Secret: Post "https://192.168.56.100:6443/api/v1/namespaces/kube-system/secrets?timeout=10s": tls: failed to verify certificate: x509: certificate signed by unknown authority (possibly because of "crypto/rsa: verification error" while trying to verify candidate authority certificate "kubernetes")
To see the stack trace of this error execute with --v=5 or higher
> Error 2: cannot get the join command
5. For Error 2, GPT says it is due to not installed Flannel 
- try to install Flannel by `sudo kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/v0.26.7/Documentation/kube-flannel.yml --kubeconfig=/etc/kubernetes/admin.conf`
this gives error: error: error validating "https://raw.githubusercontent.com/flannel-io/flannel/v0.26.7/Documentation/kube-flannel.yml": error validating data: failed to download openapi: Get "https://192.168.56.100:6443/openapi/v2?timeout=32s": dial tcp 192.168.56.100:6443: connect: connection refused; if you choose to ignore these errors, turn validation off with --validate=false
> Error 3: cannot install Flannel
5. manually join the node-1 with command directly copied from the output of the ctrl's `kubeadm init ....` command
```
sudo kubeadm join 192.168.56.100:6443 --token 2qnwp1.iatq704p8b9p85pv \
        --discovery-token-ca-cert-hash sha256:d20810d45ec6535c0731e7a5b43cf54a04d793ee5f5141ff64256fae10208f87
```
This works.

## Conclusion:
1. The `kubeadm init .....` command is not running correctly, so the kube-apiserver is not started correctly, affecting the following part.
2. In principle, we should be able to manually start it again in ctrl's terminal, and run the following part, but maybe there is still some problem with that kube-apiserver, or some other problem, we cannot get the command join correctly, so the joining procedure still cannot be automated.