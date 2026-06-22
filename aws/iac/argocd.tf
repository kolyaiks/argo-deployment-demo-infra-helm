resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "9.5.14"

  namespace = "argocd"

  create_namespace = true

  depends_on = [module.eks]
}

## App of Apps entrypoint application | TODO: Uncomment once the EKS cluster is created, kubectl context is set, and ArgoCD is up and running
# resource "kubernetes_manifest" "argocd_bootstrap_app" {
#   manifest = {
#     apiVersion = "argoproj.io/v1alpha1"
#     kind       = "Application"
#
#     metadata = {
#       name      = "platform-bootstrap"
#       namespace = "argocd"
#       finalizers = ["resources-finalizer.argocd.argoproj.io"] ## to delete all the managed apps when the root app is deleted
#     }
#
#     spec = {
#       project = "default"
#
#       source = {
#         repoURL        = "https://github.com/kolyaiks/argo-deployment-demo-gitops.git"
#         targetRevision = "main"
#         path           = "argocd-apps"
#       }
#
#       destination = {
#         server    = "https://kubernetes.default.svc"
#         namespace = "argocd"
#       }
#
#       syncPolicy = {
#         automated = {
#           prune    = true
#           selfHeal = true
#         }
#
#         syncOptions = [
#           "CreateNamespace=true",
#           "PruneLast=true",
#           "ApplyOutOfSyncOnly=true"
#         ]
#       }
#     }
#   }
#
#   depends_on = [
#     helm_release.argocd
#   ]
# }