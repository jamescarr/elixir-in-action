.PHONY: help build run test_add_entry test_entries

# Docker build command
# Build the Docker image
build_docker: ## Build the Docker image
	docker build . -t elixir-in-action/todo

# Docker run command
# Run the Docker container
run_docker: ## Run the Docker container
	docker run \
		--rm -it \
		--name todo_system \
		-p "5454:5454" \
		elixir-in-action/todo

# Test add entry
# Add a new entry
test_add_entry: ## Add a new entry. Usage: make test_add_entry list=bob date=2023-12-19 title="Dentist"
	@curl -d "" \
		"http://localhost:5454/add_entry?list=$(list)&date=$(date)&title=$(title)"

# Test entries
# Get entries for a specific date
test_entries: ## Get entries for a specific date. Usage: make test_entries list=bob date=2023-12-19
	@curl "http://localhost:5454/entries?list=$(list)&date=$(date)"

# Default task
.DEFAULT_GOAL := help

# Help task
help: ## Display this help
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
