# gcs-retention-lock
A Makefile to help you make WORM compliant GCS buckets, and see how they work.

# Overview
This Makefile's default target will run an interactive sequence of operations to create a WORM compliant bucket in GCS. Before anything, an overview is provided, and each step has an explanation and user confirmation.

This script is a companion to a [Google Cloud solution](http://cloud.google.com/solutions) and is intended for educational purposes. However, the variables in the Makefile can be modified for "live fire" use to create WORM compliant object storage buckets.

# Usage:

To see the steps to create a WORM bucket, simply run `make`.

To create a test object in the WORM bucket, run `make test_object`.

To delete the test object (which may fail by design if the retention period is not met), run `make delete_test_object`.

To clean up the buckets, run `make delete_buckets`.
