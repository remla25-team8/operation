#!/bin/bash
set -e

echo "📦 Installing dependencies..."
sudo apt update
sudo apt install -y curl git wget apt-transport-https ca-certificates gnupg python3-pip
pip3 install kubernetes

echo "📥 Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "📡 Adding Helm repos..."
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

echo "🚪 Installing Istio base components..."
kubectl create namespace istio-system || true
helm install istio-base istio/base -n istio-system --version 1.25.2 --wait
helm install istiod istio/istiod -n istio-system --version 1.25.2 --wait

echo "🚥 Installing Istio Ingress Gateway..."
kubectl create namespace istio-ingress || true
helm install istio-ingress istio/gateway -n istio-ingress --version 1.25.2 --wait

echo "🔁 Enabling sidecar injection..."
kubectl label namespace default istio-injection=enabled --overwrite

echo "📊 Installing Prometheus and Grafana..."
kubectl create namespace monitoring || true
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --wait

echo "✅ All components installed. You can now deploy your app."
