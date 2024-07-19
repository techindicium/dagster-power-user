SHELL := /bin/bash
export SHELLOPTS := pipefail:errexit

ORDERED_STACKS := ("base" "core" "locations" "dagster")

.PHONY: deploy retract restart

.ONESHELL:

deploy:
	stacks=$(ORDERED_STACKS)
	for stack in "$${stacks[@]}"
	do
		bash scripts/deploy.sh $$stack
	done

retract:
	stacks=$(ORDERED_STACKS)
	for (( idx=$${#stacks[@]}-1 ; idx>=0 ; idx-- ))
	do
		bash scripts/retract.sh $${stacks[idx]}
	done

restart:
	aws ecs update-service --force-new-deployment --service dagster-daemon --cluster dagster-ecs-poc-cluster
	aws ecs update-service --force-new-deployment --service dagster-webserver --cluster dagster-ecs-poc-cluster
