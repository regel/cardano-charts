/*
Copyright © 2021 Sebastien Leger

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
package cmd

import (
	"fmt"

	"context"
	"encoding/json"
	"github.com/spf13/cobra"
	"io/ioutil"
	"os"
	"time"

	"github.com/go-redis/redis/v8"
)

var (
	Addr     string
	Password string
	Topic    string
	Output   string
)

// subscribeCmd represents the subscribe command
var subscribeCmd = &cobra.Command{
	Use:   "subscribe",
	Short: "Subscribe to Cardano node topology updates",
	Long: `Shelley has been launched without peer-to-peer (p2p) node discovery so that means we will need to manually add trusted nodes in order to configure our topology. This is a critical step as skipping this step will result in your minted blocks being orphaned by the rest of the network.

This command receives topology updates via Redis Pub/Sub. Data is written o the specified output file.`,
	Run: subscribe,
}

func init() {
	rootCmd.AddCommand(subscribeCmd)
	subscribeCmd.Flags().StringVarP(&Addr, "addr", "a", "redis:6379", "Redis server address")
	subscribeCmd.Flags().StringVarP(&Password, "password", "p", "", "Redis password")
	subscribeCmd.Flags().StringVarP(&Topic, "topic", "t", "cardano", "Topic to subscribe to")
	subscribeCmd.Flags().StringVarP(&Output, "output", "o", "", "Output file path")
	subscribeCmd.MarkFlagRequired("output")
}

func isJSON(s string) bool {
	var js map[string]interface{}
	return json.Unmarshal([]byte(s), &js) == nil

}

func subscribe(cmd *cobra.Command, args []string) {
	// Create a new Redis Client
	redisClient := redis.NewClient(&redis.Options{
		Addr:     Addr,
		Password: Password,
		DB:       0,
	})
	err := redisClient.Ping(context.Background()).Err()
	if err != nil {
		time.Sleep(3 * time.Second)
		err := redisClient.Ping(context.Background()).Err()
		if err != nil {
			panic(err)
		}
	}
	ctx := context.Background()
	topic := redisClient.Subscribe(ctx, Topic)
	channel := topic.Channel()
	for msg := range channel {
		if !isJSON(msg.Payload) {
			err := fmt.Errorf("invalid json")
			panic(err)
		}
		tmp, err := ioutil.TempFile("", "tempfile")
		if err != nil {
			panic(err)
		}
		if _, err := tmp.Write([]byte(msg.Payload)); err != nil {
			panic(err)
		}
		if err := tmp.Close(); err != nil {
			panic(err)
		}
		if err := os.Rename(tmp.Name(), Output); err != nil {
			panic(err)
		}
	}
}
