### Advanced Exercise: Using ConfigMaps and Secrets

**Scenario:**

You need to deploy a web application that requires configuration data and sensitive information such as database credentials. The application should be configured using a ConfigMap and a Secret, ensuring that the sensitive information is securely managed.

### Requirements:

1. **Create a Namespace:**
   - Create a namespace named `web-app`.

2. **Create a ConfigMap:**
   - Create a ConfigMap named `web-config` in the `web-app` namespace with the following data:
     - `APP_COLOR`: "blue"
     - `APP_MODE`: "production"

3. **Create a Secret:**
   - Create a Secret named `db-secret` in the `web-app` namespace with the following data:
     - `DB_USER`: "admin"
     - `DB_PASSWORD`: "password"

4. **Deploy a Pod:**
   - Deploy a pod named `web-pod` in the `web-app` namespace using the `nginx` image.
   - Configure the pod to use the environment variables from the ConfigMap and Secret.

### Steps to Complete the Task:

1. **Create the Namespace:**

   ```bash
   kubectl create namespace web-app
   ```

2. **Create the ConfigMap:**

   ```bash
   kubectl create configmap web-config --namespace=web-app --from-literal=APP_COLOR=blue --from-literal=APP_MODE=production
   ```

3. **Create the Secret:**

   ```bash
   kubectl create secret generic db-secret --namespace=web-app --from-literal=DB_USER=admin --from-literal=DB_PASSWORD=password
   ```

4. **Define the Pod with Environment Variables:**

   See file `web-pod.yml`

5. **Apply the Pod Manifest:**

   ```bash
   kubectl apply -f web-pod.yaml
   ```

### Verification Steps:

1. **Check the Pod Status:**

   ```bash
   kubectl get pods -n web-app
   ```

2. **Describe the Pod to Ensure Environment Variables are Set:**

   ```bash
   kubectl describe pod web-pod -n web-app
   ```

3. **Check the Environment Variables inside the Pod:**

   ```bash
   kubectl exec -n web-app -it web-pod -- env | grep -E 'APP_COLOR|APP_MODE|DB_USER|DB_PASSWORD'
   ```

### Terraform automation

   See the file `exercise1.tf`
