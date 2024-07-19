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

resource "kubernetes_namespace" "Autoscale-namespace" {
  metadata {
    name = "autoscale-app"
  }
}


resource "kubernetes_deployment" "Web-deployment" {
  metadata {
    name = "web-deployment"
    namespace = kubernetes_namespace.Autoscale-namespace.metadata.0.name
    labels = {
      test = "web-app"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        test = "web-app"
      }
    }

    template {
      metadata {
        labels = {
          test = "web-app"
        }
      }

      spec {
        container {
          image = "nginx"
          name  = "web-container"

        }
      }
    }
  }

  depends_on = [kubernetes_namespace.Autoscale-namespace]
}


resource "kubernetes_service" "Web-service" {
  metadata {
    name = "web-service"
    namespace = kubernetes_namespace.Autoscale-namespace.metadata.0.name
  }
  spec {
    selector = {
      test = "web-app"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.Web-deployment]
}


resource "kubernetes_horizontal_pod_autoscaler_v1" "Web-service-autoscaler" {
  metadata {
    name = "web-service-autoscaler"
    namespace = kubernetes_namespace.Autoscale-namespace.metadata.0.name
  }

  spec {
    max_replicas = 10
    min_replicas = 1
    target_cpu_utilization_percentage = 50

    scale_target_ref {
      kind = "Deployment"
      name = kubernetes_deployment.Web-deployment.metadata.0.name
    }
  }

  depends_on = [kubernetes_deployment.Web-deployment]
}