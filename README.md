# kubernetes
This repository contains my experience in using Kubernetes in my private home cluster
and control it using terraform.


### Step-by-Step Guide to Reinitialize the Cluster with Cilium

### Step 1: Clean Up Existing Cluster

1. **Reset the `kubeadm` state:**

   ```bash
   sudo kubeadm reset -f
   ```

2. **Remove Kubernetes configuration directories:**

   ```bash
   sudo rm -rf /etc/kubernetes /var/lib/etcd /var/lib/kubelet /etc/cni /var/lib/cni
   ```

3. **Restart the Kubelet service:**

   ```bash
   sudo systemctl restart kubelet
   sudo systemctl restart crio
   ```

### Step 2: Reinitialize the Master Node

1. **Initialize the Kubernetes master node:**

   ```bash
   sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket=unix:///var/run/crio/crio.sock
   ```

2. **Set up kubeconfig for the regular user:**

   ```bash
   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config
   ```

### Step 3: Remove the Taint from the Master Node

1. **Remove the taint from the master node to allow scheduling pods:**

   ```bash
   kubectl taint nodes --all node-role.kubernetes.io/control-plane-
   kubectl taint nodes --all node-role.kubernetes.io/master-
   ```


### Step 4: Deploy Calico

1. **Install the Calico operator

   ```bash
   kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
   ```

2. **Modify and install the CRD**

   ```bash
   wget https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml
   # Modify the cidr, then:
   kubectl create -f custom-resources.yaml
   ```

3. **Verify Calico installation:**

   ```bash
   watch kubectl get pods -n calico-system
   ```

### Step 5: Verify the Cluster

1. **Check the status of the nodes:**

   ```bash
   kubectl get nodes
   ```

2. **Ensure all pods are running:**

   ```bash
   kubectl get pods --all-namespaces
   ```

### Step 6: Reinstall Metrics Server

1. **Apply the Metrics Server deployment:**

   ```bash
   kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
   ```

   Or use HELM to install.

   ```bash
   $ helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
   $ k create namespace metrics-server
   namespace/metrics-server created
   $ k config set-context --current --namespace metrics-server
   Context "kubernetes-admin@kubernetes" modified.
   $ helm upgrade --install metrics-server metrics-server/metrics-server
   Release "metrics-server" does not exist. Installing it now.
   NAME: metrics-server
   LAST DEPLOYED: Fri Jul 19 09:38:56 2024
   NAMESPACE: metrics-server
   STATUS: deployed
   REVISION: 1
   TEST SUITE: None
   NOTES:
   ***********************************************************************
   * Metrics Server                                                      *
   ***********************************************************************
   Chart version: 3.12.1
   App version:   0.7.1
   Image tag:     registry.k8s.io/metrics-server/metrics-server:v0.7.1
   ***********************************************************************
   ```

2. **Edit the Metrics Server deployment to add the `--kubelet-insecure-tls` flag:**

   ```bash
   kubectl edit deployment metrics-server -n kube-system
   ```

   Add the `--kubelet-insecure-tls` argument to the container's args:

   ```yaml
   spec:
     containers:
     - args:
       - --cert-dir=/tmp
       - --secure-port=10250
       - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
       - --kubelet-use-node-status-port
       - --metric-resolution=15s
       - --kubelet-insecure-tls
   ```

3. **Check the status of the Metrics Server:**

   ```bash
   kubectl get deployment metrics-server -n kube-system
   ```

4. **Check the logs of the Metrics Server pod:**

   ```bash
   kubectl logs -n kube-system -l k8s-app=metrics-server
   ```

### Summary

By following these steps, you can reset and reinstall your Kubernetes cluster using `kubeadm` on CentOS with Cilium as the CNI plugin. This includes cleaning up the existing cluster, reinitializing the master node, deploying Cilium, removing the taint from the master node to allow pod scheduling, and ensuring the Metrics Server is properly configured and running. If you encounter any issues, please let me know, and I can assist you further.
