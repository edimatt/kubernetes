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

### Step 3: Deploy Cilium

1. **Install the Cilium CLI:**


2. **Deploy Cilium:**

   ```bash
   cilium install
   ```

3. **Verify Cilium installation:**

   ```bash
   cilium status --wait
   ```

### Step 4: Remove the Taint from the Master Node

1. **Remove the taint from the master node to allow scheduling pods:**

   ```bash
   kubectl taint nodes --all node-role.kubernetes.io/control-plane-
   kubectl taint nodes --all node-role.kubernetes.io/master-
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
