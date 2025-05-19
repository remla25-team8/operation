This folder is shared in:
- VM: /mnt/shared
- Pods: /root/mount

To test the shared folder:
1. deploy as readme.md
```
vagrant up
ansible-playbook -u vagrant -i 192.168.56.100, ansible/finalization.yaml
vagrant ssh ctrl
cd /vagrant/k8s
kubectl apply -f .
```
2. terminal into pods
```
kubectl get pods
kubectl get pods -l app=app-service # get the name
```
```
kubectl exec -it <pod-name> -- /bin/sh
```
```
ls /root/mount
```