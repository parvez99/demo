# pmulani-api

A minimal **Python FastAPI** microservice that does CRUD on **PostgreSQL (RDS)**, deployed to **Amazon EKS**, fronted by **ingress-nginx** with **TLS via cert-manager**, packaged with **Helm**, shipped by **CircleCI** to **ECR**, and instrumented for **Prometheus/Grafana** (optional **Datadog** logs).

**Demo:** `https://demo.pmulani.com`  
**Docs:** `https://demo.pmulani.com/docs`  
**Health:** `/livez` (process), `/readyz` (DB)


## What's covered

- **App URL** `https://demo.pmulani.com` and **Swagger** at `/docs`
- **CircleCI** project (green pipeline: test → build → deploy) : Any changes pushed to the repo (main) are immediately rolled out by circleci.
- **ECR** image tagged with the commit SHA
- **Grafana** dashboard (simple dashboard)
- **Datadog** Live Tail filtered to `service:pmulani-api`
- **Security** PSS with restricted policy applied.
- **DDoS mitigations**: app rate-limits + body cap + nginx rate limits, Shield Standard on NLB, private RDS, secrets as files.

Everything is deployed to EKS with Autoscaling enabled.

---

## Repository layout

```
.
├── .circleci/
│   └── config.yml                # CI: test → build/push → deploy (EKS via Helm)
├── README.md                     
├── terraform/                    # VPC, EKS (1.33), RDS, ECR, IRSA, etc.
├── kubernetes/                   # add-ons (ingress, cert-manager, ebs-csi, alb, monitoring)
│   ├── cert-manager/
│   ├── ingress-nginx/
│   ├── aws-load-balancer-controller/
│   ├── ebs-csi/
│   └── monitoring/               # Promethues, Grafana, ServiceMonitor
├── charts/                       # Helm chart for the pmulani-api app
│   ├── Chart.yaml
│   ├── values.yaml               # non-secret config (ingress, resources, etc.)
│   ├── values-secrets-ci.yaml    # use an existing K8s Secret (no plaintext in CI)
│   └── templates/                # deployment, service, ingress, (secret optional)
└── pmulaniapi/                   # Python microservice
    ├── main.py                   # reads DB_* via *_FILE envs (mounted Secret files)
    ├── requirements.txt
    ├── Dockerfile
```

---

## Prerequisites

- AWS CLI v2, kubectl, Helm 3, Terraform, Docker (with buildx)
- DNS `demo.pmulani.com` → **ALIAS/CNAME** to the **ingress-nginx** NLB hostname
- `sops` + `helm-secrets` for encrypted values
- (Optional) Datadog API key

---

## 1) Provision infrastructure (Terraform)

From `terraform/`:

```bash
terraform init
terraform plan --var-file=pmulani-prod-eu-west-1.tfvars
terraform apply --var-file=pmulani-prod-eu-west-1.tfvars
```

Outputs include: **EKS cluster name**, **RDS endpoint**, **ECR repo URL**, **OIDC provider ARN**, etc.

---

## 2) Cluster add-ons

Most of the cluster addons are deployed using helm and stored under kubernetes folder. Each values file contains instructions on how to deploy the addon.
### 2.1 ingress-nginx (NLB, IP mode)

### 2.2 cert-manager (CRDs + production ClusterIssuer)

```bash
cat <<'YAML' | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: you@example.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef: { name: letsencrypt-prod }
    solvers:
      - http01:
          ingress:
            class: nginx
YAML
```

> EBS CSI & AWS Load Balancer Controller are installed with IRSA (see `kubernetes/`).

---

## 3) Build & push the app image (ECR)

From `pmulaniapi/`:

```bash
ACCOUNT_ID=<your-account-id>
REGION=<aws-region>
REPO_URL="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/pmulani-api"
IMAGE_TAG=v0.2.4

aws ecr get-login-password --region "$REGION" |   docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

docker buildx create --use --name cross 2>/dev/null || docker buildx use cross
docker buildx build --platform linux/amd64   -t "$REPO_URL:$IMAGE_TAG" -t "$REPO_URL:latest" . --push
```

---

## 4) Database secrets (K8s Secret mounted as files)

K8s secret that deployment mounts it at `/etc/db`, and the app reads `DB_*` via `*_FILE` envs.

In `charts/values-secrets-ci.yaml`:

```yaml
dbSecret:
  create: false
existingDbSecret: api-db
```

---

## 5) Deploy the app (Helm)

`charts/values.yaml` sets:
- `service.type: ClusterIP`
- Ingress host: **demo.pmulani.com** with TLS via `letsencrypt-prod`
- Prometheus scrape annotations (or ServiceMonitor, below)

Deploy:

```bash
 helm secrets upgrade --install pmulani-api ./charts \
  -n customer -f charts/values.yaml -f charts/values-secret-sops.yaml

kubectl -n customer rollout status deploy/pmulani-api
```

Verify:

```bash
# NLB hostname vs your domain
kubectl -n ingress-nginx get svc ingress-nginx-controller   -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'; echo
dig +short demo.pmulani.com

# App OK
curl -I https://demo.pmulani.com/healthz
curl -s https://demo.pmulani.com/readyz
```

---

## 6) CRUD quick start

**Swagger:** `https://demo.pmulani.com/docs`

```bash
# Create
curl -s -X POST https://demo.pmulani.com/customers   -H 'content-type: application/json'   -d '{"name":"Alice","email":"alice@example.com"}'

# List
curl -s https://demo.pmulani.com/customers

# Get by ID
curl -s https://demo.pmulani.com/customers/1

# Update
curl -s -X PUT https://demo.pmulani.com/customers/1   -H 'content-type: application/json'   -d '{"name":"Alice A.","email":"alice.a@example.com"}'

# Delete
curl -i -X DELETE https://demo.pmulani.com/customers/1
```

Validation: invalid email → **422**; duplicate email → **409**.

---

## 7) Observability (Prometheus / Grafana)

### 7.1 ServiceMonitor (kube-prometheus-stack)

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: pmulani-api
  namespace: customer
  labels:
    release: prometheus-pmulani                 # set to your Prometheus release label
spec:
  namespaceSelector:
    matchNames: ["customer"]
  selector:
    matchLabels:
      app: pmulani-api                 
  endpoints:
    - port: http                        # Service port name (80 → targetPort 8000)
      path: /metrics
      interval: 15s
```

### 7.2 Grafana (starter queries)

https://grafana.pmulani.com/
Please reach out for login details.
---

## 8) Datadog logs:


### 8.1 Install Agent (logs on)

```bash
kubectl create namespace datadog 2>/dev/null || true
kubectl -n datadog create secret generic datadog-api-key   --from-literal api-key='<YOUR_DD_API_KEY>'

helm repo add datadog https://helm.datadoghq.com
helm upgrade --install datadog datadog/datadog -n datadog --create-namespace   --set datadog.site=datadoghq.com   --set datadog.apiKeyExistingSecret=datadog-api-key   --set datadog.logs.enabled=true   --set datadog.logs.containerCollectAll=true   --set datadog.logs.containerCollectUsingFiles=true   --set clusterAgent.enabled=true   --set datadog.kubeStateMetricsCore.enabled=true
```

### 8.2 Tag the app logs (Helm values)

```yaml
podAnnotations:
  ad.datadoghq.com/api.logs: >-
    [{"source":"python","service":"pmulani-api","tags":["env:demo","app:pmulani-api"]}]
```

View in Datadog → Logs (filter `service:pmulani-api`).

---

## 9) DDoS & abuse protection

- **App**: IP rate-limit (`RATE_LIMIT_RPM`, default 60/min/IP) → HTTP **429**; request body cap (`MAX_BODY_BYTES`, default 1 MiB) → **413**; safe SQL via SQLAlchemy params; secrets mounted as files; `/livez` vs `/readyz`.
- **Ingress (optional)** add rate limits to Ingress annotations:

  ```yaml
  nginx.ingress.kubernetes.io/limit-rps: "5"
  nginx.ingress.kubernetes.io/limit-burst: "10"
  nginx.ingress.kubernetes.io/proxy-body-size: "1m"
  ```

- **Network**: NLB benefits from **AWS Shield Standard**; RDS is private (security-group limited).

---

## 10) CircleCI (CI/CD)

**Where:** `.circleci/config.yml` (pipeline runs in CircleCI’s cloud, not in your cluster).  
Jobs: `test` (pytest) → `build_and_push` (ECR) → `deploy_eks` (Helm).

### 10.1 Project env vars (CircleCI → Project Settings → Environment Variables)

```
AWS_REGION=eu-west-1
AWS_ACCOUNT_ID=<account_id>
ECR_REPO_NAME=pmulani-api
EKS_CLUSTER_NAME=pmulani-prod-eks-eu-west-1
K8S_NAMESPACE=customer
HELM_RELEASE=pmulani-api
# Auth: either static keys OR role assumption
AWS_ACCESS_KEY_ID=...           # if using access keys
AWS_SECRET_ACCESS_KEY=...
DEPLOY_ROLE_ARN=arn:aws:iam::<acount-id>:role/Circle-CI-Role   # if assuming a role
```
---
## 11) What's next

Apply network policies to restrict access to the cluster and deployed services.

### Challenges ###

- Getting circle-ci integrated with EKS cluster took some attempts but I figured a way to use Assume Role over plain AWS credentials.
