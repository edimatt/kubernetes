Sure, let’s add more specific details to the web applications and their communication.

### Detailed Exercise: Deploy and Manage a Multi-Container Application

#### Objective:
Deploy a multi-container application using Kubernetes and manage its lifecycle.

#### Scenario:
You are tasked with deploying a simple web application consisting of a frontend and a backend. The frontend is a Node.js application, and the backend is a Python Flask application. They should communicate with each other within the cluster.

### Application Details:

**Backend (Python Fastapi):**
- The backend provides a simple API endpoint that returns a JSON response.
- Endpoint: `/api/data`
- JSON Response: `{"message": "Hello from Flask backend"}`

**Frontend (Node.js):**
- The frontend has a single route that fetches data from the backend and displays it.
- Route: `/`
- Display: `Message from backend: Hello from Flask backend`

### Requirements:

1. **Set Up the Cluster:**
   - Ensure you have access to a Kubernetes cluster.

2. **Create Namespace:**
   - Create a new namespace called `ckad-exercise`.

3. **Backend Application:**
   - **Dockerize the Flask Application:**
     - Create a Dockerfile for the Flask backend application.
     - Ensure it installs necessary dependencies and runs the application.
   - **Kubernetes YAML for Backend:**
     - Create a Deployment with 2 replicas.
     - Create a Service to expose the backend on port 5000.
   - **FastAPI Application Code:**

     ```python
      from fastapi import FastAPI
      from pydantic import BaseModel

      app = FastAPI()

      class DataResponse(BaseModel):
          message: str

      @app.get("/api/data", response_model=DataResponse)
      async def get_data():
          return DataResponse(message="Hello from FastAPI backend")

      if __name__ == "__main__":
          import uvicorn
          uvicorn.run(app, host="0.0.0.0", port=80)
     ```

4. **Frontend Application:**
   - **Dockerize the Node.js Application:**
     - Create a Dockerfile for the Node.js frontend application.
     - Ensure it installs necessary dependencies and runs the application.
   - **Kubernetes YAML for Frontend:**
     - Create a Deployment with 2 replicas.
     - Create a Service to expose the frontend on port 3000.
     - Set an environment variable `BACKEND_URL` to the backend service URL.
   - **Node.js Application Code:**
     ```javascript
     const express = require('express');
     const axios = require('axios');

     const app = express();
     const backendUrl = process.env.BACKEND_URL || 'http://backend:5000/api/data';

     app.get('/', async (req, res) => {
         try {
             const response = await axios.get(backendUrl);
             res.send(`Message from backend: ${response.data.message}`);
         } catch (error) {
             res.send('Error fetching data from backend');
         }
     });

     const port = 3000;
     app.listen(port, () => {
         console.log(`Frontend running on port ${port}`);
     });
     ```

5. **ConfigMaps and Secrets:**
   - Use a ConfigMap to manage the configuration for the frontend application.
   - Use a Secret to store sensitive information such as database credentials (if any).

6. **Volume Management:**
   - Attach a PersistentVolume to the backend application to persist data.

7. **Rolling Updates:**
   - Perform a rolling update on the frontend application without downtime.

8. **Resource Limits and Requests:**
   - Set appropriate resource requests and limits for both the frontend and backend applications.

9. **Health Checks:**
   - Implement liveness and readiness probes for both applications to ensure proper health monitoring.

10. **Scaling:**
    - Manually scale the backend application to handle increased load.

11. **Clean Up:**
    - Delete all the resources created in the `ckad-exercise` namespace.

### Deliverables:
- Dockerfiles for both frontend and backend applications.
- Kubernetes YAML files for:
  - Namespace
  - Deployments
  - Services
  - ConfigMaps
  - Secrets
  - PersistentVolumes and PersistentVolumeClaims (if used)
- Steps to perform rolling updates and scaling.

### Tips:
- Use `kubectl` commands to interact with your cluster.
- Make sure to validate your YAML files.
- Test the communication between the frontend and backend services.
- Ensure all resources are cleaned up after completing the exercise.

Good luck with your preparation!
