#!/bin/bash

echo Creating CloudSQL Stop Schedueler..

echo Please enter GCP Location:
read LOCATION
echo Ok, GCP Location set to: $LOCATION

echo Please enter GCP Service Account Name:
read SERVICEACCOUNT_NAME
echo Ok, GCP Service Account set to: $SERVICEACCOUNT_NAME

echo Please enter GCP Project ID:
read PROJECT
echo Ok, GCP Project ID set to: $PROJECT

echo Please enter GCP CloudSQL Instance name:
read INSTANCE
echo Ok, GCP CloudSQL Instance set to: $INSTANCE

echo Creating Service-Account..
gcloud iam service-accounts create $SERVICEACCOUNT_NAME

SERVICEACCOUNT="${SERVICEACCOUNT_NAME}@${PROJECT}.iam.gserviceaccount.com"
echo $SERVICEACCOUNT

gcloud projects add-iam-policy-binding $PROJECT \
    --member "serviceAccount:${SERVICEACCOUNT}" \
    --role "roles/workflows.invoker"

gcloud projects add-iam-policy-binding $PROJECT \
    --member "serviceAccount:${SERVICEACCOUNT}" \
    --role "roles/logging.logWriter"

gcloud projects add-iam-policy-binding $PROJECT \
    --member "serviceAccount:${SERVICEACCOUNT}" \
    --role "roles/cloudsql.editor"

echo Deploying Workflows..
WORKFLOW_STOP=cloudsqlStop
WORKFLOW_START=cloudsqlStart

echo Deploying Stop Workflow..
gcloud workflows deploy $WORKFLOW_STOP \
    --source=./workflows/cloudsql.stop.workflows.yaml \
    --service-account=${SERVICEACCOUNT} \
    --location=${LOCATION}

echo Deploying Start Workflow
gcloud workflows deploy $WORKFLOW_START \
    --source=./workflows/cloudsql.start.workflows.yaml \
    --service-account=${SERVICEACCOUNT} \
    --location=${LOCATION}

echo Deploying Cronjobs..

echo Deploying Stop Cronjob
gcloud scheduler jobs create http "${WORKFLOW_STOP}Cronjob" \
    --schedule="0 18 * * *" \
    --uri="https://workflowexecutions.googleapis.com/v1/projects/${PROJECT}/locations/${LOCATION}/workflows/${WORKFLOW_STOP}/executions" \
    --message-body="{\"argument\": \"{\\\"project\\\":\\\"${PROJECT}\\\",\\\"instance\\\":\\\"${INSTANCE}\\\"}\"}" \
    --time-zone="Europe/Berlin" \
    --oauth-service-account-email="${SERVICEACCOUNT}" \
    --location=${LOCATION}

echo Deploying Start Cronjob
gcloud scheduler jobs create http "${WORKFLOW_START}Cronjob" \
    --schedule="0 8 * * *" \
    --uri="https://workflowexecutions.googleapis.com/v1/projects/${PROJECT}/locations/${LOCATION}/workflows/${WORKFLOW_START}/executions" \
    --message-body="{\"argument\": \"{\\\"project\\\":\\\"${PROJECT}\\\",\\\"instance\\\":\\\"${INSTANCE}\\\"}\"}" \
    --time-zone="Europe/Berlin" \
    --oauth-service-account-email="${SERVICEACCOUNT}" \
    --location=${LOCATION}