#!/usr/bin/env bash
# Configure our Docker container during Travis builds

# Show all commands and exit upon failure
set -eux

# By default, Travis's ccache size is around 500MB. We'll
# start with 2GB just to see how it plays out.
ccache -M 2G

# Enable compression so that we can have more objects in
# the cache (9 is most compressed, 6 is default)
ccache --set-config=compression=true
ccache --set-config=compression_level=9

# Set the cache directory to /travis/.ccache, which we've
# bind mounted during 'docker create' so that we can keep
# this cached across builds
ccache --set-config=cache_dir=/travis/.ccache

# Clear out the stats so we actually know the cache stats
ccache -z
