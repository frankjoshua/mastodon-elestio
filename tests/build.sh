#!/usr/bin/env bash
docker buildx build . --output type=docker,name=elestio4test/mastodon:latest | docker load
