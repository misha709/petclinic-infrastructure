variable "queues" {
  type        = set(string)
  description = "Set of SQS queue names to create — each gets its own _error dead-letter queue"
}

variable "irsa_role_arn" {
  type        = string
  description = "ARN of the IRSA role granted send/receive access on all queues"
}

variable "visibility_timeout_seconds" {
  type        = number
  description = "How long a message is invisible after being received — should be >= your consumer processing timeout"
  default     = 30
}

variable "max_receive_count" {
  type        = number
  description = "Number of times a message can be received before being moved to the DLQ"
  default     = 5
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to all resources"
  default     = {}
}
