#!/bin/bash

.PHONY: deploy retract restart

ORDERED_STACKS="base" "core" "locations" "dagster"

.ONESHELL:

deploy:
	for stack in $(ORDERED_STACKS)
	do
		bash scripts/deploy.sh "`echo $$stack`"
	done

retract:
	for (( idx=${#ORDERED_STACKS[@]}-1 ; idx>=0 ; idx-- ))
	do
		stack="${ORDERED_STACKS[idx]}"
		bash scripts/retract.sh $stack
	done

restart:
	aws ecs update-service --force-new-deployment --service dagster-daemon --cluster dagster-ecs-poc-cluster
	aws ecs update-service --force-new-deployment --service dagster-webserver --cluster dagster-ecs-poc-cluster
