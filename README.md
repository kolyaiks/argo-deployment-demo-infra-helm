## Order of apply:

#### 1. Setting up the base AWS infrastructure
1. `aws/iac` folder - `terraform apply --auto-approve` to create base infrastructure

#### 2. Preparing the GitOps repo 
1. take `vpc_id` from TF output and then use it `https://github.com/kolyaiks/argo-deployment-demo-gitops/blob/main/platform/aws-load-balancer-controller/values.yaml`
2. (optional, won't be changed in case of the same account) take `alb_sa_role` from TF output and then use it in `https://github.com/kolyaiks/argo-deployment-demo-gitops/blob/main/platform/aws-load-balancer-controller/values.yaml`
3. (optional, won't be changed in case of the same account) take `aws_role_for_k8s_service_account_dev` from TF output and then use it in `https://github.com/kolyaiks/argo-deployment-demo-gitops/blob/main/workloads/argo-deployment-demo-app/values-dev.yaml`
4. (optional, won't be changed in case of the same account) take `aws_role_for_k8s_service_account_prod` from TF output and then use it in `https://github.com/kolyaiks/argo-deployment-demo-gitops/blob/main/workloads/argo-deployment-demo-app/values-prod.yaml`

#### 3. Deploying the App-of-Apps ArgoCD application
1. `aws eks update-kubeconfig --region us-east-1 --name argo-deployment-demo-cluster` - setting up the context for a new cluster, name may vary
2. `kubectl get secrets argocd-initial-admin-secret -o yaml -n argocd` - getting the secret we'll need to an `admin` user, it's in base64, so we'll need to decrypt
3. `kubectl port-forward svc/argocd-server -n argocd 8080:80` - proxy local port 8080 to argocd's ui pod
4. `https://localhost:8080/` - in browser getting the ArgoCD UI
5. going to `aws/iac/argocd.tf` and uncommenting `argocd_bootstrap_app` resource that represents the app-of-apps
6. `aws/iac` folder - `terraform apply --auto-approve` to deploy the ArgoCD app-of-apps that then deploys the remaining apps from `argocd-apps` folder in `main` branch here `https://github.com/kolyaiks/argo-deployment-demo-gitops/tree/main/argocd-apps`
7. once the `external-gateway` ArgoCD app is deployed, you should see an alb deployed in AWS console, grab the DNS name for it, go to `aws/iac/r53.tf`, set the alb DNS name there, then re-deploy Terraform

## Important notice about working with NAT instances

Once this repo is cloned from GitHub, before doing `terraform apply` make sure to check Line Separators for .sh scripts in `modules/nat` they should be using linux format equal to`LF`.
Otherwise, you have a risk of facing weird issues when userdata script will fail and, as a result, Network Interface with EIP tied to it will not be attached to the newly created NAT instance.

Also, make sure not to do Instance Refresh for ASG used for NAT instance when the new instance is being created before the old one is deleted - unless Network Interface isn't unattached from the old instance, the new one won't be able to attach it, script that's doing it will fail.