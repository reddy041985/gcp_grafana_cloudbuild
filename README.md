1. Project Initialization
Ensure your GCP project is set up and you are authenticated in your terminal:

Bash

gcloud auth login
gcloud config set project gcp-test-cloudbuild


2. Infrastructure Setup (One-time)
Run the following commands to set up the "storage" and "identity" layers.

Artifact Registry: Create the Docker repository.

BigQuery: Create the sales_analytics dataset.

IAM: Create the sales-runner service account and grant logging.logWriter and run.developer roles.

3. Deploy via Cloud Build
The build is automated using the cloudbuild.yaml file. You can trigger it manually using the CLI:

Bash

gcloud builds submit --config cloudbuild.yaml .
What happens during the build:

Build: Cloud Build packages the /app folder into a Docker image.

Push: The image is uploaded to your Artifact Registry.

Deploy: Cloud Build tells Cloud Run to start a new revision using that image.

4. Continuous Deployment (Git Trigger)
To automate this every time you push code:

Go to Cloud Build > Triggers in the GCP Console.

Connect your Git Repository.

Set the event to Push to a branch.

Point the configuration to the cloudbuild.yaml file in your root directory.

1. Generate Sales
Once the build is successful, get your URL and trigger sales:

Bash

export URL=$(gcloud run services describe sales-api --region us-central1 --format='value(status.url)')
curl "$URL/generate-sale?item_id=ABC&amount=99.99"
2. Grafana Configuration
DataSource: BigQuery.

Authentication: Service Account JSON Key (ensure it has BigQuery Data Viewer and Job User).

Query:

SQL

SELECT
  SUM(CAST(jsonPayload.amount AS FLOAT64)) as total_revenue
FROM
  `[PROJECT_ID].sales_analytics.run_googleapis_com_stdout_*`
WHERE
  jsonPayload.event = "sale"
📁 Repository Structure
/app: Python FastAPI source code and Dockerfile.

/terraform: Infrastructure as Code (Variables and Main config).

cloudbuild.yaml: CI/CD pipeline definition.