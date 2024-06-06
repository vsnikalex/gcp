# Career::T2::GCP::CLI

## Create a bucket
```bash
gsutil mb gs://<BUCKET_NAME>
```

## Copy file to bucket
```bash
gsutil cp [MY_FILE] gs://[BUCKET_NAME]
```

## List available regions
```bash
gcloud compute regions list
```

## Linux: set environment variables from file
```bash
nano .profile
source infraclass/config
```

## Switching between projects
```bash
export PROJECT_1_ID=my-first-project
gcloud set project $PROJECT_1_ID
```

## List the available VPC networks
```bash
gcloud compute networks list
```

## List the available VPC subnets
```bash
gcloud compute networks subnets list --sort-by=NETWORK
```

## List all the firewall rules
```bash
gcloud compute firewall-rules list --sort-by=NETWORK
```

## List all VM instances
```bash
gcloud compute instances list --sort-by=ZONE
```

## Connect to VM via SSH
```bash
gcloud compute ssh vm-internal --zone us-central1-c --tunnel-through-iap
```

## Linux: open cron table
```bash
sudo crontab -e
```

## Starting|stopping|deleting instances
```bash
gcloud compute instances start|stop|delete INSTANCE_NAMES
```

## Create a snapshot of a disk
```bash
gcloud compute disks snapshot DISK_NAME --snapshot-names=NAME
```

## Create an image
```bash
gcloud compute images create IMAGE_NAME
```

## List the names and basic information of all clusters
```bash
gcloud container clusters list
```

## Describe a cluster named `standard-cluster-1` located in the `us-central1-a` zone
```bash
gcloud container clusters describe --zone us-central1-a standard-cluster-1
```

## Configure the `kubeconfig` file on a cluster `standard-cluster-1` in the `use-central1-a` zone
```bash
gcloud container clusters get-credentials --zone us-central1-a standard-cluster-1
```

## List the pods|nodes in a cluster
```bash
kubectl get pods|nodes
```

## Start|expose|delete a service
```bash
kubectl run hello-server --image=gcr.io/google/samples/hello-app:1.0 --port 8080
kubectl expose deployment hello-server --type="LoadBalancer"
kubectl delete service hello-server
```

## List the contents of an image registry
```bash
gcloud container images list
```

## Split traffic between App Engine versions
```bash
gcloud app services set-traffic serv1 --splits v1=.4,v2=.6
```

## Deploy|delete Cloud Pub/Sub function called `pub_sub_function_test`
```bash
gcloud functions deploy pub_sub_function_test --runtime python37 --trigger-topic gcp-ace-exam-test-topic
gcloud functions delete pub_sub_function_test
```

## Connect to a MySQL instance called `ace-exam-mysql`
```bash
gcloud sql connect ace-exam-mysql –user=root
```

## Create Pub/Sub topic
```bash
gcloud pubsub topics create [TOPIC-NAME]
```

## Create Pub/Sub subscription
```bash
gcloud pubsub subscriptions create [SUBSCRIPTION-NAME] ––topic [TOPIC-NAME]
```

## Change the access controls on a bucket
* The gsutil acl ch command changes access permissions. 
* The -u parameter specifies the user. 
* The :W option indicates that the user should have write access to the bucket.
```bash
gsutil acl ch -u [SERVICE_ACCOUNT_ADDRESS]:W gs://[BUCKET_NAME]
```

## Create MySQL database dump
```bash
gcloud sql export sql [INSTANCE_NAME] gs://[BUCKET_NAME]/[FILE_NAME] --database=[DATABASE_NAME]
```

## Import MySQL dump
```bash
gcloud sql import sql [INSTANCE_NAME] gs://[BUCKET_NAME]/[IMPORT_FILE_NAME] --database=[DATABASE_NAME]
```

## Increase the number of addresses in ace-exam-subnet1 to 65,536
```bash
gcloud compute networks subnets expand-ip-range ace-exam-subnet1 --prefix-length 16
```

## Reserve an IP address
```bash
gcloud beta compute addresses create ace-exam-reserved-static1 --region=us-west2 --network-tier=PREMIUM
```

## See a list of users and roles assigned across a project
```bash
gcloud projects get-iam-policy [PROJECT_NAME]
```

## Assign roles to a member in a project
```bash
gcloud projects add-iam-policy-binding [RESOURCE-NAME] --member user:[USER-EMAIL] --role [ROLE-ID]
```

## Define a custom role
```bash
gcloud iam roles create [ROLE-ID] --project [PROJECT-ID] --title [ROLE-TITLE] --description [ROLE-DESCRIPTION] --permissions [PERMISSIONS-LIST] --stage [LAUNCH-STAGE]
```

## Execute `gcloud` command on behalf of a SA
```bash
gcloud config set account <SERVICE_ACCOUNT_NAME>
gcloud auth application-default login
gcloud config get-value account
```
