#!/bin/bash

protoc --elixir_out=plugins=grpc:apps/helay_server/lib/helay_server hooks.proto
protoc --elixir_out=plugins=grpc:apps/helay_client/lib/helay_client hooks.proto
