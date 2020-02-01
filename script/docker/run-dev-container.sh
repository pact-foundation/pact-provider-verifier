#!/bin/sh

docker run -it --rm -v ${PWD}:/app pact-provider-verifier-dev:latest bash
