### Demo project accompanying a [Consul crash course video](https://www.youtube.com/watch?v=s3I1kKKfjtQ) on YouTube

Credit: [nanachi](https://github.com/nanuchi) manual Fork from [Gitlab Repo](https://gitlab.com/twn-youtube/consul-crash-course)

## Requirement

**AWS CLI**  [installing guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)  
**Kubectl**  [installing guide](https://kubernetes.io/docs/tasks/tools/)  
**Consul**   [installing guide](https://developer.hashicorp.com/consul/docs/k8s/installation/install)  
**Helm 3.6+** [installing guide](https://helm.sh/docs/intro/install/)  


## Create a `terraform.tfvars` file** in the terraform directory.  

Add your AWS credentials like this:
 
 ```hcl
 aws_access_key_id     = "YOUR_AWS_ACCESS_KEY_ID"
 aws_secret_access_key = "YOUR_AWS_SECRET_ACCESS_KEY"
 ```
 
## Note:  
 You need AWS credentials with permissions to:
 
 - Manage EC2 (VPCs, subnets, security groups)
 - Manage EKS (clusters and nodegroups)
 - Manage IAM (roles and policies)
 - Manage CloudWatch Logs
 
 If unsure, attach the **AdministratorAccess** policy to your IAM user.
 
 ---

## Terraform commands to execute the script

```sh
# initialise project & download providers
terraform init

# preview what will be created with apply & see if any errors
terraform plan

# exeucute with preview
terraform apply -var-file terraform.tfvars

# execute without preview
terraform apply -var-file terraform.tfvars -auto-approve

# destroy everything
terraform destroy

# show resources and components from current state
terraform state list
```

## Get access to EKS cluster
```sh
# install and configure awscli with access creds
aws configure

# check existing clusters list
aws eks list-clusters --region eu-central-1 --output table --query 'clusters'

# check config of specific cluster - VPC config shows whether public access enabled on cluster API endpoint
aws eks describe-cluster --region eu-central-1 --name myapp-eks-cluster --query 'cluster.resourcesVpcConfig'

# create kubeconfig file for cluster in ~/.kube
aws eks update-kubeconfig --region eu-central-1 --name myapp-eks-cluster

# test configuration
kubectl get svc
```

## Get access to LKE cluster

```sh
# Set env variable KUBECONFIG
# Download kubeconfig.yaml file from Linode kubernetes

# for Windows Powershell
$env:KUBECONFIG = '{PATH_TO_KUBECONFIG_FILE}'

# for MacOs Terminal
export KUBECONFIG={PATH_TO_KUBECONFIG_FILE}

# test configuration
kubectl get svc
```

## Deployment

### EKS cluster (Main cloud provider)

```sh
helm install eks hashicorp/consul --version 1.0.0 --values consul-values.yaml --set global.datacenter=eks

Kubectl apply -f config-consul.yaml
Kubectl apply -f consul-mesh-gateway.yaml
Kubectl apply -f service-resolver.yaml
```

### LKE cluster (Backup cloud provider)

```sh
helm install lke hashicorp/consul --version 1.0.0 --values consul-values.yaml --set global.datacenter=lke

Kubectl apply -f config-consul.yaml
Kubectl apply -f consul-mesh-gateway.yaml
Kubectl apply -f exported-service.yaml
```

