# Command to create a Docker for the Endpoints
# gcloud run deploy biblosphere-api \
#    --image="gcr.io/endpoints-release/endpoints-runtime-serverless:2" \
#    --allow-unauthenticated \
#    --platform managed \
#    --project=biblosphere-210106

# Upload Endpoints configuration
# gcloud endpoints services deploy openapi-functions.yaml --project biblosphere-210106

# Build an image
# ./gcloud_build_image -s biblosphere-api-ihj6i2l2aq-uc.a.run.app -c 2020-06-22r0 -p biblosphere-210106

# Redeploy Docker
# gcloud run deploy biblosphere-api --image="gcr.io/biblosphere-210106/endpoints-runtime-serverless:biblosphere-api-ihj6i2l2aq-uc.a.run.app-2020-06-22r0" --allow-unauthenticated --platform managed --project=biblosphere-210106

# Get permission to access functions
# gcloud functions add-iam-policy-binding add_books --member "serviceAccount:779249096383-compute@developer.gserviceaccount.com" --role "roles/cloudfunctions.invoker" --project biblosphere-210106
# gcloud functions add-iam-policy-binding search_book --member "serviceAccount:779249096383-compute@developer.gserviceaccount.com" --role "roles/cloudfunctions.invoker" --project biblosphere-210106
# gcloud functions add-iam-policy-binding add_user_books_from_image --member "serviceAccount:779249096383-compute@developer.gserviceaccount.com" --role "roles/cloudfunctions.invoker" --project biblosphere-210106
# gcloud functions add-iam-policy-binding add_user_books --member "serviceAccount:779249096383-compute@developer.gserviceaccount.com" --role "roles/cloudfunctions.invoker" --project biblosphere-210106
# gcloud functions add-iam-policy-binding get_book --member "serviceAccount:779249096383-compute@developer.gserviceaccount.com" --role "roles/cloudfunctions.invoker" --project biblosphere-210106
# gcloud functions add-iam-policy-binding add_cover --member "serviceAccount:779249096383-compute@developer.gserviceaccount.com" --role "roles/cloudfunctions.invoker" --project biblosphere-210106
# gcloud functions add-iam-policy-binding add_back --member "serviceAccount:779249096383-compute@developer.gserviceaccount.com" --role "roles/cloudfunctions.invoker" --project biblosphere-210106
# gcloud functions add-iam-policy-binding get_tags --member "serviceAccount:779249096383-compute@developer.gserviceaccount.com" --role "roles/cloudfunctions.invoker" --project biblosphere-210106


# Create pubsub topic
# gcloud pubsub topics create add_user_books_from_image

# Try API
# export ENDPOINTS_HOST=biblosphere-api-ihj6i2l2aq-uc.a.run.app
# curl --request GET --header "content-type:application/json" --header "Authorization:Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjZmY2Y0MTMyMjQ3NjUxNTZiNDg3NjhhNDJmYWMwNjQ5NmEzMGZmNWEiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIzMjU1NTk0MDU1OS5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsImF1ZCI6IjMyNTU1OTQwNTU5LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwic3ViIjoiMTE2NDYwNDE2MTIxMzU4MTIyNjI1IiwiZW1haWwiOiJkc3RhcmsxOTc3QGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJhdF9oYXNoIjoiM2I0dFFxeDJ1a1gwcEkzeTV6QVJVUSIsImlhdCI6MTU4NjMyNzczMCwiZXhwIjoxNTg2MzMxMzMwfQ.HNDkupQh9yvL6RKmet_G5NQvsLtXMsq4aRtHPIbtZ20ouGO0Yz61_r1cK599OUeGoJKSLaELUi9T36DNC1NYECw26qclYxn5wx8M4M-6xb6REic7lNK6aJsOEMCI_j6rnpCuInkMV-9GKIsAJ3DCt3zV7wWDtQNJZFlQAqRrs-PrVsFeSWzDKiWSQ4vZoeOQ4d0Waj9B1LDIciPz_Z7xIwWcxG0olHYKHqxtCy9DnbQTgpBdzf4lmc4F7CxUwQgNo-j1C9-jsvI2bq8PKBOSscKVWKbbvrvJ-G3SU-j-ANXqxFjIYEfbhzLievJicwedGGPSAl0m4Hmz7Dn1EIKrgQ" "https://${ENDPOINTS_HOST}/http_auth_test"

# gcloud auth print-identity-token