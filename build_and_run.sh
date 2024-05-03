#! /usr/bin/env bash
docker build -t mycanister2 .
docker run -it -v .:/canister --rm -p 4943:4943 --name my_rust_journey mycanister2