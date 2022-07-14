docs:
	terraform-docs ./

precommit_test:
	pre-commit install
	pre-commit run --files $$(git diff --name-only origin)
