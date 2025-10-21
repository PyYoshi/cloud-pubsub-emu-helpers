FROM gcr.io/google.com/cloudsdktool/cloud-sdk:544.0.0-emulators

EXPOSE 8086
VOLUME /var/pubsub

CMD [ "gcloud", "--quiet", "beta", "emulators", "pubsub", "start", "--host-port=0.0.0.0:8086", "--data-dir=/var/pubsub" ]
