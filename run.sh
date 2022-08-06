#!/bin/bash
docker run -it --rm --name infra-workspace -v $(pwd):/workspace -v ~/.ssh/k8s.freggy.dev:/root/.ssh/k8s.freggy.dev infra-workspace
