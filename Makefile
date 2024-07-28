.PHONY: help build run

# Docker build command
# Build the Docker image
build: ## Build the Docker image
	docker build . -t elixir-in-action/todo

# Docker run command
# Run the Docker container
run: ## Run the Docker container
	docker run \
		--rm -it \
		--name todo_system \
		-p "5454:5454" \
		elixir-in-action/todo

# Default task
.DEFAULT_GOAL := help

# Help task
help: ## Display this help
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
