terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kubernetes-admin@kubernetes"
}

resource "kubernetes_namespace" "Web-namespace" {
  metadata {
    name = "web-app"
  }
}

resource "kubernetes_config_map" "Web-configmap" {
  metadata {
    name = "web-config"
    namespace = kubernetes_namespace.Web-namespace.metadata[0].name
  }

  data = {
    APP_COLOR = "blue"
    APP_MODE  = "production"
  }

  depends_on = [ kubernetes_namespace.Web-namespace ]
}

resource "kubernetes_secret" "Web-secret" {
  metadata {
    name = "db-config"
    namespace = kubernetes_namespace.Web-namespace.metadata[0].name
  }

  data = {
    DB_USER = "admin"
    DB_PASSWORD = "password"
  }

  type = "Opaque"
  depends_on = [ kubernetes_namespace.Web-namespace ]
}

resource "kubernetes_pod" "Web-pod" {
  metadata {
    name = "web-pod"
    namespace = kubernetes_namespace.Web-namespace.metadata[0].name
  }

  spec {
    container {
      image = "nginx"
      name  = "web-container"

      env_from {
        config_map_ref {
          name = kubernetes_config_map.Web-configmap.metadata[0].name
        }
      }

      env_from {
        secret_ref {
          name = kubernetes_secret.Web-secret.metadata[0].name
        }
      }
    }
  }

  depends_on = [ 
    kubernetes_config_map.Web-configmap,
    kubernetes_secret.Web-secret
   ]
}
