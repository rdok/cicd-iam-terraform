# cicd-iam-terraform
Automate IAM for CI/CD using terraform.

### Current approach
For each repository generate a new CI/CD user with corresponding policies.

### Next approach
Generate a single CI/CD user. For reach repository create a role with required policies.

Let the CI/CD assume relevant role on demand.

# Develop

See `Makefile`
