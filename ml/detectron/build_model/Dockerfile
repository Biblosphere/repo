FROM python:3.7

RUN apt-get update && apt-get install -y git

# Copy local code to the container image.
ENV APP_HOME /app
WORKDIR $APP_HOME
COPY . ./

RUN ls -la $APP_HOME/

# Install dependencies
RUN pip install -r requirements.txt

# Install detectron2
RUN git clone https://github.com/facebookresearch/detectron2.git
RUN pip install -e detectron2

ENV PORT 5000

# Run the flask service on container startup
CMD [ "python", "DetectronFlask.py" ]


# to build container (first go to directory 'repo_build_model'):
# gcloud builds submit --tag gcr.io/biblosphere-210106/detectron-model . --timeout=3600

# view containers, info, logs:
# gcloud builds list --filter detectron-model
# gcloud builds describe 380549ff-913c-4ac3-b0b1-6dfe25af527c
# gcloud builds log 380549ff-913c-4ac3-b0b1-6dfe25af527c


# deploy container
# gcloud run deploy demo-docker-model --image gcr.io/biblosphere-210106/detectron-model --platform managed --memory 4G