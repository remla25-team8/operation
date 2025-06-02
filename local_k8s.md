# Local start of k8s and app
### 1. add the permission and run
```
cd /vagrant
chmod +x finalization_local.sh
./finalization_local.sh
```

### 2. start the app from command line
```
cd /vagrant/helm/myapp
helm install dev-myapp . --set namePrefix=dev
```

### 3. forward the port to visit it via localhost
```
kubectl port-forward svc/istio-ingress -n istio-ingress 8080:80
curl -H "Host: app.local" http://localhost:8080/analyze
```



