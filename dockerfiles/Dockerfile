FROM gcr.io/google.com/cloudsdktool/cloud-sdk:380.0.0

USER 0

RUN \
    apt-get update \
    && apt-get install -y google-cloud-sdk google-cloud-sdk-pubsub-emulator \
    && mkdir -p /var/pubsub

COPY ./run.bash /

# 直接起動できなくなったのでbashから起動する
CMD ["/bin/bash", "/run.bash"]
