.PHONY: download upload upload-processed pg-load dbt-deps dbt-run dbt-test all tf-init tf-apply spark test local-extract local-pg-load local-all

download:
	python scripts/download_data.py

upload:
	python scripts/upload_to_s3.py

upload-processed:
	python scripts/upload_processed_to_s3.py

spark:
	python spark/transform_events.py

pg-load:
	python scripts/load_to_postgres.py

dbt-deps:
	cd dbt && dbt deps --project-dir . --profiles-dir .

dbt-run:
	cd dbt && dbt deps --project-dir . --profiles-dir . && dbt run --project-dir . --profiles-dir .

dbt-test:
	cd dbt && dbt test --project-dir . --profiles-dir .

test:
	pytest tests/ -v

all: local-all

local-all: local-extract spark local-pg-load dbt-run dbt-test

tf-init:
	cd terraform && terraform init

tf-plan:
	cd terraform && terraform plan

tf-apply:
	cd terraform && terraform apply -auto-approve

tf-destroy:
	cd terraform && terraform destroy

local-extract:
	python scripts/extract_local_dataset.py

local-pg-load:
	python scripts/load_local_to_postgres.py
