# ── Node Group Role ────────────────────────────────────────────────────────────
# Attached to every EC2 worker so the kubelet can register with the cluster,
# pull images from ECR, and use the VPC CNI plugin.

resource "aws_iam_role" "node_group" {
  count = var.create_node_role ? 1 : 0

  name = "${var.cluster_name}-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "node_group_worker" {
  count      = var.create_node_role ? 1 : 0
  role       = aws_iam_role.node_group[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_group_cni" {
  count      = var.create_node_role ? 1 : 0
  role       = aws_iam_role.node_group[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_group_ecr" {
  count      = var.create_node_role ? 1 : 0
  role       = aws_iam_role.node_group[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "node_group" {
  count = var.create_node_role ? 1 : 0

  name = "${var.cluster_name}-node-group-profile"
  role = aws_iam_role.node_group[0].name

  tags = var.tags
}

# ── IRSA Pod Role ──────────────────────────────────────────────────────────────
# Allows pods running under a specific Kubernetes service account to call AWS
# APIs (SQS, Secrets Manager) without static credentials.
# Requires the EKS OIDC provider to already exist — see create_irsa_role flag.

resource "aws_iam_role" "irsa" {
  count = var.create_irsa_role ? 1 : 0

  name = "${var.cluster_name}-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = var.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(var.oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:${var.irsa_namespace}:${var.irsa_service_account}"
          "${replace(var.oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = var.tags
}

# NOTE: Scope these down per-service in production — use inline policies with
# specific queue ARNs / secret ARNs instead of the broad managed policies below.
resource "aws_iam_role_policy_attachment" "irsa_sqs" {
  count      = var.create_irsa_role ? 1 : 0
  role       = aws_iam_role.irsa[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_role_policy_attachment" "irsa_secrets" {
  count      = var.create_irsa_role ? 1 : 0
  role       = aws_iam_role.irsa[0].name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}
