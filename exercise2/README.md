### Advanced Exercise: Configuring Horizontal Pod Autoscaling (HPA) with Metrics Server

**Scenario:**

You are managing a Kubernetes cluster for a web application. The application needs to automatically scale its pods based on CPU usage to handle varying loads efficiently. You need to configure Horizontal Pod Autoscaling (HPA) for this application, and ensure the Metrics Server is deployed and properly configured to provide the necessary metrics.

### Requirements:

1. **Install Metrics Server:**
   - Ensure the Metrics Server is installed and running in your cluster.

2. **Create a Namespace:**
   - Create a namespace named `autoscale-app`.

3. **Deploy a Deployment:**
   - Deploy a Deployment named `web-deployment` in the `autoscale-app` namespace using the `nginx` image.
   - Configure the Deployment with 3 replicas initially.
   - Expose the Deployment as a service named `web-service` on port 80.

4. **Configure HPA:**
   - Create an HPA resource for the `web-deployment` to scale the pods based on CPU usage.
   - Set the target CPU utilization to 50%.
   - Configure the HPA to scale between 1 and 10 replicas.

### Steps to Complete the Task:

1. **Install the Metrics Server:**

   If the Metrics Server is not already installed, you can install it using the following commands:

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

   Verify that the Metrics Server is running:

   ```bash
   kubectl get deployment metrics-server -n kube-system
   ```

2. **Create the Namespace:**

   ```bash
   kubectl create namespace autoscale-app
   ```

3. **Define the Deployment:**

   Create a file named `web-deployment.yaml` with the following content:

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: web-deployment
     namespace: autoscale-app
   spec:
     replicas: 3
     selector:
       matchLabels:
         app: web-app
     template:
       metadata:
         labels:
           app: web-app
       spec:
         containers:
         - name: nginx
           image: nginx
           resources:
             requests:
               cpu: 100m
             limits:
               cpu: 200m
   ```

4. **Apply the Deployment:**

   ```bash
   kubectl apply -f web-deployment.yaml
   ```

5. **Expose the Deployment as a Service:**

   Create a file named `web-service.yaml` with the following content:

   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: web-service
     namespace: autoscale-app
   spec:
     selector:
       app: web-app
     ports:
       - protocol: TCP
         port: 80
         targetPort: 80
   ```

   Apply the service:

   ```bash
   kubectl apply -f web-service.yaml
   ```

6. **Define the Horizontal Pod Autoscaler:**

   Create a file named `web-hpa.yaml` with the following content:

   ```yaml
   apiVersion: autoscaling/v2beta2
   kind: HorizontalPodAutoscaler
   metadata:
     name: web-hpa
     namespace: autoscale-app
   spec:
     scaleTargetRef:
       apiVersion: apps/v1
       kind: Deployment
       name: web-deployment
     minReplicas: 1
     maxReplicas: 10
     metrics:
     - type: Resource
       resource:
         name: cpu
         target:
           type: Utilization
           averageUtilization: 50
   ```

7. **Apply the HPA:**

   ```bash
   kubectl apply -f web-hpa.yaml
   ```

### Verification Steps

1. **Check the Deployment and Pods:**

   ```bash
   kubectl get deployments -n autoscale-app
   kubectl get pods -n autoscale-app
   ```

2. **Check the Service:**

   ```bash
   kubectl get services -n autoscale-app
   ```

3. **Check the Horizontal Pod Autoscaler:**

   ```bash
   kubectl get hpa -n autoscale-app
   ```

4. **Generate Load to Test Autoscaling:**

   You can use a tool like `kubectl exec` to generate CPU load on the pods:

   ```bash
   kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://web-service.autoscale-app.svc.cluster.local; done"
   ```

   After a while, check the HPA status again to see if it has scaled the pods:

   ```bash
   kubectl get hpa -n autoscale-app
   kubectl get pods -n autoscale-app
   ```

### Summary

This exercise involves setting up a Horizontal Pod Autoscaler (HPA) for a deployment, ensuring the Metrics Server is running to provide necessary metrics, and configuring the HPA to scale based on CPU usage. These are crucial concepts within the scope of Kubernetes application management and autoscaling.
