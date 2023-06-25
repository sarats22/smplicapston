resource "aws_iam_role" "eks_node_role" {
  name = "example-node-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action    = "sts:AssumeRole"
    }]
  })

  # Add additional configuration for the role, such as permissions policies
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "example-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.21"

  vpc_config {
    subnet_ids = ["subnet-0f3c663cdc0a9a91d"]  # Replace with your subnet IDs
    # Other VPC configuration options
  }
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "example-node-group"
  subnet_ids      = [aws_subnet.public.id]  # Replace with your subnet IDs
  node_role_arn   = aws_iam_role.eks_node_role.arn  # Replace with your node role ARN

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  # Other configuration options for the node group
}

