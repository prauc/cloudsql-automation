# GCP CloudSQL automation

Automatically stop and start CloudSQL Instance via `Cloud Scheduler` and `Cloud Workflows`.

## Project setup

```
chmod +x ./cloudsql-workflow-automation.sh
./cloudsql-workflow-automation.sh
```

## Input Parameters

### Location

Your GCP region. e.g. `europe-west4`

### Service Account Name

Service Account Name for `Service Account` to be created.

### GCP Project ID

Your GCP Project ID.

### CloudSQL Instance

Your GCP CloudSQL Instance to automate.
