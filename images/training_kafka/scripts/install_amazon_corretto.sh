#!/usr/bin/env bash
set -eu -o pipefail

sudo amazon-linux-extras enable corretto8

sudo yum -y install java-1.8.0-amazon-corretto
