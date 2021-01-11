#!/bin/bash

gcloud beta emulators pubsub start --host-port=0.0.0.0:8086 --data-dir=/var/pubsub --verbosity debug
