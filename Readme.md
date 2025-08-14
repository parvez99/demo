# pmulani-api — EKS + RDS + Helm + CI/CD + Observability

A minimal customer CRUD microservice (FastAPI + PostgreSQL) deployed on **EKS** behind **ingress-nginx** with **TLS (cert-manager)**, packaged by **Helm**, built and shipped by **CircleCI** to **ECR**, with **Prometheus/Grafana** metrics and optional **Datadog** logs.

## Architecture (high level)

- **Terraform**: VPC, EKS (v1.33), RDS Postgres, ECR, IRSA (OIDC), EBS CSI.
- **Kubernetes add-ons**: ingress-nginx (NLB), cert-manager (Let’s Encrypt), AWS Load Balancer Controller, EBS CSI.
- **App**: FastAPI service (CRUD), SQLAlchemy (param queries), pydantic validation, Prometheus metrics @ `/metrics`.
- **Security/DDoS**: app-level IP rate-limit + body size cap, optional nginx rate limits, secrets mounted as files, RDS not internet-exposed.
- **Obs**: kube-prometheus-stack + Grafana; optional Datadog Agent for logs.

Public demo: **https://demo.pmulani.com**  
Docs: **https://demo.pmulani.com/docs**  
Health: `/livez` (process), `/readyz` (DB)

---

## 1) Prerequisites

- AWS CLI, kubectl, Helm, Terraform, Docker (buildx), (optional) `sops` + `helm-secrets`.
- A DNS record `demo.pmulani.com` pointing (ALIAS/CNAME) to the **ingress-nginx** NLB.
- Datadog API key (optional).

---

## 2) Provision infra (Terraform)

From `terraform/`:

```bash
terraform init
terraform apply \
  -var 'region=eu-west-1' \
  -auto-approve
