
resource "aws_iam_role" "role_eks" {

    name = "eks role"
    assume_role_policy = jsonencode(
      { "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Principal" : {
              "Service" : "eks.amazonaws.com"
            },
            "Action" : "sts:AssumeRole"
  
          }
        ]
      }
    )
  
  
  }
  
  
  resource "aws_iam_policy" "policy_eks" {
  
    name = "policy for eks"
    policy = jsonencode({
      "PolicyVersion" : {
        "Document" : {
          "Version" : "2012-10-17",
          "Statement" : [
            {
              "Effect" : "Allow",
              "Action" : [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:UpdateAutoScalingGroup",
                "ec2:AttachVolume",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateRoute",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:DeleteRoute",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteVolume",
                "ec2:DescribeInstances",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVolumes",
                "ec2:DescribeVolumesModifications",
                "ec2:DescribeVpcs",
                "ec2:DescribeDhcpOptions",
                "ec2:DetachVolume",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifyVolume",
                "ec2:RevokeSecurityGroupIngress",
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
                "elasticloadbalancing:AttachLoadBalancerToSubnets",
                "elasticloadbalancing:ConfigureHealthCheck",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateLoadBalancerListeners",
                "elasticloadbalancing:CreateLoadBalancerPolicy",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeleteLoadBalancerListeners",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeLoadBalancerPolicies",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:DetachLoadBalancerFromSubnets",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
                "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
                "kms:DescribeKey"
              ],
              "Resource" : "*"
            },
            {
              "Effect" : "Allow",
              "Action" : "iam:CreateServiceLinkedRole",
              "Resource" : "*",
              "Condition" : {
                "StringLike" : {
                  "iam:AWSServiceName" : "elasticloadbalancing.amazonaws.com"
                }
              }
            }
          ]
        },
        "VersionId" : "v3",
        "IsDefaultVersion" : true,
        "CreateDate" : "2019-05-22T22:04:46Z"
      }
    })
  
  }
  
  resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
    policy_arn = aws_iam_policy.policy_eks.arn
  
    role = aws_iam_role.role_eks.name
  }
  
  
  
  resource "aws_eks_cluster" "cluster" {
  
    name = "eks cluster"
  
    role_arn = aws_iam_role.role_eks.arn
  
    version = "1.29"
  
  
    vpc_config {
  
      endpoint_public_access = true
  
      subnet_ids = [
        aws_subnet.private_subnet1.id,
        aws_subnet.private_subnet2.id,
        aws_subnet.subnet1.id,
        aws_subnet.subnet2.id,
      ]
    }
  
    depends_on = [aws_iam_policy_attachment.eks_attach_policy]
  
  }
  
  
  
  
  
  resource "aws_iam_role" "role_node_group" {
  
    name = "eks role"
    assume_role_policy = jsonencode(
      { "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Principal" : {
              "Service" : "ec2.amazonaws.com"
            },
            "Action" : "sts:AssumeRole"
  
          }
        ]
      }
    )
  
  
  }
  
  resource "aws_iam_policy" "worker_node_policy" {
  
    policy = jsonencode({
      "PolicyVersion" : {
        "Document" : {
          "Version" : "2012-10-17",
          "Statement" : [
            {
              "Action" : [
                "ec2:DescribeInstances",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVolumes",
                "ec2:DescribeVolumesModifications",
                "ec2:DescribeVpcs",
                "eks:DescribeCluster"
              ],
              "Resource" : "*",
              "Effect" : "Allow"
            }
          ]
        },
        "VersionId" : "v1",
        "IsDefaultVersion" : true,
        "CreateDate" : "2018-05-27T21:09:01Z"
      }
    })
  
  }
  
  
  resource "aws_iam_policy" "cmi_policy" {
  
    policy = jsonencode({
      "PolicyVersion" : {
        "Document" : {
          "Version" : "2012-10-17",
          "Statement" : [
            {
              "Effect" : "Allow",
              "Action" : [
                "ec2:AssignPrivateIpAddresses",
                "ec2:AttachNetworkInterface",
                "ec2:CreateNetworkInterface",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeInstances",
                "ec2:DescribeTags",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DetachNetworkInterface",
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:UnassignPrivateIpAddresses"
              ],
              "Resource" : "*"
            },
            {
              "Effect" : "Allow",
              "Action" : [
                "ec2:CreateTags"
              ],
              "Resource" : [
                "arn:aws:ec2:*:*:network-interface/*"
              ]
            }
          ]
        },
        "VersionId" : "v3",
        "IsDefaultVersion" : true,
        "CreateDate" : "2019-06-27T18:10:37Z"
      }
    })
  
  }
  
  
  
  
  
  resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
    policy_arn = aws_iam_policy.worker_node_policy.arn
  
    role = aws_iam_role.role_node_group.name
  }
  
  resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  
    policy_arn = aws_iam_role.role_node_group.arn
  
    role = aws_iam_role.role_node_group.name
  }
  
  
  resource "aws_eks_node_group" "node_group" {
  
    cluster_name = aws_eks_cluster.cluster.name
  
    node_role_arn = aws_iam_role.role_node_group.arn
  
    subnet_ids = [
      aws_subnet.private_subnet1,
    aws_subnet.private_subnet2]
  
    scaling_config {
      desired_size = 1
  
      min_size = 1
  
      max_size = 2
    }
    ami_type = "AL2_x86_64"
  
    capacity_type = "ON DEMAND"
  
    disk_size = 20
  
    force_update_version = false
  
    instance_types = ["t3.micro"]
  
  
    depends_on = [
      aws_iam_role_policy_attachment.amazon_eks_cni_policy,
      aws_iam_role_policy_attachment.amazon_eks_worker_node_policy
  
    ]
  
  
  }
  
  