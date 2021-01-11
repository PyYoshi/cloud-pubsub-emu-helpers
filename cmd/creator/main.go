package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"time"

	"cloud.google.com/go/pubsub"
	"google.golang.org/api/option"
)

var (
	flagProjectID     string
	flagTopic         string
	flagSubscriptions stringItems
)

type stringItems []string

func (i *stringItems) String() string {
	return fmt.Sprintf("%v", *i)
}

func (i *stringItems) Set(v string) error {
	*i = append(*i, v)

	return nil
}

func init() {
	flag.Usage = usage

	flag.StringVar(&flagProjectID, "project", "", "Specify Google Cloud Project ID")
	flag.StringVar(&flagTopic, "topic", "", "Specify Cloud Pub/Sub topic name")
	flag.Var(&flagSubscriptions, "subscription", "Specify Cloud Pub/Sub subscription name")
}

func usage() {
	_, _ = fmt.Fprintf(flag.CommandLine.Output(), "Usage of %s:\n", os.Args[0])
	flag.PrintDefaults()
	_, _ = fmt.Fprint(flag.CommandLine.Output(), "Must set specify \"PUBSUB_EMULATOR_HOST\" as an Environment variable\n")
	_, _ = fmt.Fprint(flag.CommandLine.Output(), "https://cloud.google.com/sdk/gcloud/reference/beta/emulators/pubsub/\n")
}

func main() {
	flag.Parse()

	if flagProjectID == "" || flagTopic == "" || os.Getenv("PUBSUB_EMULATOR_HOST") == "" {
		flag.Usage()
		os.Exit(1)
	}

	if err := create(context.Background(), flagProjectID, flagTopic, flagSubscriptions); err != nil {
		panic(err)
	}
}

func create(
	ctx context.Context,
	projectID string,
	topicName string,
	subscriptionNames []string,
) error {
	pubsubClient, err := pubsub.NewClient(
		ctx,
		projectID,
		option.WithoutAuthentication(),
	)
	if err != nil {
		return err
	}
	defer func() {
		deferErr := pubsubClient.Close()
		if deferErr != nil {
			panic(deferErr)
		}
	}()

	topic := pubsubClient.Topic(topicName)
	topicExists, err := topic.Exists(ctx)
	if err != nil {
		return err
	}

	if !topicExists {
		topic, err = pubsubClient.CreateTopic(ctx, topicName)
		if err != nil {
			return err
		}
	}

	for _, subscriptionName := range subscriptionNames {
		var sub *pubsub.Subscription

		sub = pubsubClient.Subscription(subscriptionName)
		subExists, err := sub.Exists(ctx)
		if err != nil {
			return err
		}

		if !subExists {
			sub, err = pubsubClient.CreateSubscription(ctx, subscriptionName, pubsub.SubscriptionConfig{
				Topic:       topic,
				AckDeadline: 10 * time.Second,
			})
			if err != nil {
				return err
			}
		}
	}

	return nil
}
