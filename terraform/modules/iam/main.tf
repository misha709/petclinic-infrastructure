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

# Inline policy scoped to the exact actions MassTransit requires for SQS/SNS
# transport plus read access to Secrets Manager for DB credentials.
# MassTransit creates and manages its own queues and SNS topics on startup,
# so Create* / Delete* / Tag* actions are intentional.
resource "aws_iam_role_policy" "irsa_masstransit" {
  count = var.create_irsa_role ? 1 : 0

  name = "${var.cluster_name}-irsa-masstransit"
  role = aws_iam_role.irsa[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SqsAccess"
        Effect = "Allow"
        Action = [
          "sqs:SetQueueAttributes",
          "sqs:ReceiveMessage",
          "sqs:CreateQueue",
          "sqs:DeleteMessage",
          "sqs:SendMessage",
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility",
          "sqs:PurgeQueue",
          "sqs:DeleteQueue",
          "sqs:TagQueue",
        ]
        Resource = "arn:aws:sqs:*:*:*"
      },
      {
        Sid    = "SnsAccess"
        Effect = "Allow"
        Action = [
          "sns:GetTopicAttributes",
          "sns:ListSubscriptionsByTopic",
          "sns:GetSubscriptionAttributes",
          "sns:SetSubscriptionAttributes",
          "sns:CreateTopic",
          "sns:Publish",
          "sns:Subscribe",
          "sns:DeleteTopic",
          "sns:Unsubscribe",
          "sns:TagResource",
        ]
        Resource = "arn:aws:sns:*:*:*"
      },
      {
        Sid      = "SnsListAccess"
        Effect   = "Allow"
        Action   = ["sns:ListTopics"]
        Resource = "*"
      },
      {
        Sid    = "SecretsRead"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
        ]
        Resource = "*"
      },
    ]
  })
}
