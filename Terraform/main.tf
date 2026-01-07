provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_artifact_registry_repository" "repo" {
  format        = "DOCKER"
  repository_id = "sales-repo"
}

resource "google_bigquery_dataset" "sales_ds" {
  dataset_id = "sales_analytics"
}

resource "google_bigquery_table" "sales_table" {
  dataset_id = google_bigquery_dataset.sales_ds.dataset_id
  table_id   = "raw_sales"
  schema     = <<EOF
[
  {"name": "timestamp", "type": "TIMESTAMP"},
  {"name": "item_id", "type": "STRING"},
  {"name": "amount", "type": "FLOAT"}
]
EOF
}

resource "google_logging_project_sink" "sales_sink" {
  name        = "sales-log-sink"
  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${google_bigquery_dataset.sales_ds.dataset_id}"
  filter      = "resource.type=\"cloud_run_revision\" AND jsonPayload.event=\"sale\""
  
  unique_writer_identity = true
}

resource "google_project_iam_member" "sink_writer" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = google_logging_project_sink.sales_sink.writer_identity
}

resource "google_service_account" "run_sa" {
  account_id   = "sales-runner"
  display_name = "Cloud Run Sales Service Account"
}

resource "google_cloud_run_v2_service" "sales_service" {
  name     = "sales-api"
  location = var.region
  template {
    service_account = google_service_account.run_sa.email
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello" # Placeholder
    }
  }
}