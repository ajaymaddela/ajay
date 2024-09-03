gcloud auth login
gcloud config set project PROJECT_ID
gcloud config set compute/region REGION
gcloud config set compute/zone ZONE
gcloud compute instances list

gcloud compute instances create my-instance \
    --zone=us-central1-a \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --machine-type=n1-standard-1


gcloud container clusters create my-cluster \
    --zone=us-central1-a \
    --num-nodes=3 \
    --machine-type=n1-standard-1 \
    --enable-autoscaling \
    --min-nodes=2 \
    --max-nodes=5
