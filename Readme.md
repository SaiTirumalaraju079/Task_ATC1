This document outlines the step-by-step process for deploying a static web application in a  AWS cloud-based Kubernetes solution with logging and monitoring capabilities.


Prerequisites:

Install and configure the following tools:
   - Terraform: For infrastructure provisioning.
   - Docker: For containerizing the web application.
   - kubectl: For managing Kubernetes clusters.
   - Helm: For deploying Prometheus and Grafana.
   - AWS CLI (if using AWS).

Have access to a cloud account (AWS).

1. Infrastructure Provisioning with Terraform

    Directory Structure

        Terraform_files/
            - main.tf
            - variables.tf
            - outputs.tf

    Steps to Execute:

    a. Initialize Terraform:

      terraform init
    
    b. Run the terraform Plan:

      terraform Plan

    c. Apply the configuration:

      terraform apply



2. Dockerize the Static Web Application

    Directory Structure

       DOcker_files/
            - Dockerfile
            - index.html
    Steps to Build and Push the Image:

        a.Build the Docker image:
             docker build -t <dockerhub-username>/webapp:latest 

        b.Push the image to Docker Hub:
             docker push <dockerhub-username>/webapp:latest.

3. Kubernetes Deployment

    Directory Structure

        k8_deployment/
        - deployment.yaml
        - service.yaml

    Steps to Deploy:

        1. Apply the Kubernetes manifests:
    
            kubectl apply -f deployment.yaml
            kubectl apply -f service.yaml

        2. Verify the deployment:
     
            kubectl get pods
            kubectl get svc
        


4. Monitoring with Prometheus and Grafana

    Accessing Monitoring Tools

    i. Configuring Prometheus:

        Install the Prometheus using the helm chart.
        a.Add Prometheus helm chart repository
            helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

        b. Update helm chart repository
            helm repo update
            helm repo list
            Step 1: Create prometheus namespace
                kubectl create namespace prometheus
            Step 2- Install Prometheus
                helm install prometheus prometheus-community/prometheus--namespace
                prometheus--set alertmanager.persistentVolume.storageClass="gp2"--set server.persistentVolume.storageClass="gp2"

        B. Create IAM OIDC Provider
           ## Your cluster has an OpenID Connect (OIDC) issuer URL associated with it. To
            use AWSIdentity and Access Management (IAM) roles for service accounts,
            an IAMOIDCprovider must exist for your cluster's OIDC issuer URL. ##


            oidc_id=$(aws eks describe-cluster--name eks2--region us-east-1--query
            "cluster.identity.oidc.issuer"--output text | cut-d '/'-f 5)
            aws iam list-open-id-connect-providers | grep $oidc_id | cut-d "/"-f4
            eksctl utils associate-iam-oidc-provider--cluster eks2--approve--region
            us-east-11

        C.Create iamserviceaccount with role.

            eksctl create iamserviceaccount--name ebs-csi-controller-sa--namespace
            kube-system--cluster eks2--attach-policy-arn
            arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy--approve--role-only--role-name AmazonEKS_EBS_CSI_DriverRole--region us-east-1

            Step 1- Then attach ROLE to eks by running the following command
                Enter your account ID and cluster name.
                eksctl create addon--name aws-ebs-csi-driver--cluster eks2--service-account-role-arn
                arn:aws:iam::164297528770:role/AmazonEKS_EBS_CSI_DriverRole--force--region us-east-1

        D. View the Prometheus dashboard by forwarding the deployment ports.

            kubectl port-forward deployment/prometheus-server 9090:9090-n prometheus

    B.Configuring Grafana:


        Install Grafana
            helm repo add grafana https://grafana.github.io/helm-charts
            helm repo update

        Step 1- Create a namespace Grafana
            kubectl create namespace grafana

        Step 2- Install the Grafana
            helm install grafana grafana/grafana--namespace grafana--set
            persistence.storageClassName="gp2"--set persistence.enabled=true--set
            adminPassword='EKS!sAWSome'--set service.type=LoadBalancer

            => This command will create the Grafana service with an external load
            balancer to get the public view

        Step 3- Add the Prometheus as the datasource to Grafana
            Goto Grafana Dashboard-> Add the Datasource-> Select the Prometheus -> give prometheus URL
        
        step-4- 
           We can add some dashboard to visualise pod metrics

