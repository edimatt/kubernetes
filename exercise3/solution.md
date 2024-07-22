# Kubernetes Deployment for FastAPI and Node.js Applications

## Create Namespace and Set Context

```bash
k create namespace ckad-exercise
namespace/ckad-exercise created

k config set-context --current --namespace ckad-exercise
Context "kubernetes-admin@kubernetes" modified.
```

## Dockerfile for FastAPI Application

```Dockerfile
FROM python:3.12.4-alpine
RUN adduser -D fapi
USER fapi
WORKDIR /home/fapi
ENV PATH=/home/fapi/.local/bin:$PATH
RUN pip install fastapi
COPY app.py app.py
EXPOSE 80/tcp
CMD ["fastapi", "run", "app.py"]
```

## Build and Push FastAPI Docker Image

```bash
podman build -t docker.io/edimatt/fastapi:1.3 .
podman login
podman push docker.io/edimatt/fastapi:1.3
```

*Note: Since we are running as a normal user, we can't bind to port 80.*

## Create Deployment and Expose Service for FastAPI Application

```bash
k create deployment backend --image docker.io/edimatt/fastapi:1.3 --replicas 2 --port 8080
k expose deployment backend --name backend-srv --target-port 8080 --port 5000
```

## Dockerfile for Node.js Application

```Dockerfile
FROM node:22-alpine3.19
RUN adduser -D nuser
USER nuser
WORKDIR /home/nuser
ENV PATH=/home/nuser/.local/bin:$PATH

# Create package.json with npm init and install dependencies
RUN npm init -y \
    && npm install express axios

COPY app.js .
EXPOSE 3000
CMD ["node", "app.js"]
```

## Build and Push Node.js Docker Image

```bash
podman build -t docker.io/edimatt/nodeapp:1.0 .
podman push docker.io/edimatt/nodeapp:1.0
```

## Create ConfigMap for Backend URL

```bash
k create configmap frontend-cfg --from-literal "BACKEND_URL=http://backend-srv:5000/api/data"
```

## Create Deployment for Node.js Application

Generate the deployment YAML with `--dry-run=client`:

```bash
k create deployment frontend --image docker.io/edimatt/nodeapp:1.0 --replicas 2 --port 3000 -o yaml --dry-run=client
```

The deployment YAML:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: frontend
  name: frontend
  namespace: ckad-exercise
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  strategy: {}
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - image: docker.io/edimatt/nodeapp:1.0
        name: nodeapp
        ports:
        - containerPort: 3000
        resources: {}
        envFrom:
        - configMapRef:
            name: frontend-cfg
```

## Expose the Frontend Service

```bash
$ k expose deployment frontend --name frontend-srv --port 3000 --type NodePort
service/frontend-srv exposed
$ k get services
NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
backend-srv    ClusterIP   10.109.144.227   <none>        5000/TCP         93m
frontend-srv   NodePort    10.97.255.52     <none>        3000:32523/TCP   13m

```

We are now able to access the application via the *ClusterIP* 10.97.255.52:3000 or the *NodePort* localhost:32523
