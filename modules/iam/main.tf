# IAM Role para EC2
resource "aws_iam_role" "ec2-s3-role-webserver" {
  name = "ec2-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ec2-s3-role-webserver"
  }
}

# Permitir acesso ao bucket
resource "aws_iam_policy" "s3-read-policy" {
  name = "ec2-s3-read-policy"
  description = "Permitir EC2 ler o bucket S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::website-project-matheus",
          "arn:aws:s3:::website-project-matheus/*"
        ]
      }
    ]
  })
}

# Anexar policy a Role
resource "aws_iam_role_policy_attachment" "ec2-attach-policy" {
  role       = aws_iam_role.ec2-s3-role-webserver.name
  policy_arn = aws_iam_policy.s3-read-policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2-s3-role-webserver.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance Profile
resource "aws_iam_instance_profile" "ec2-profile-webserver" {
  name = "ec2-s3-profile"
  role = aws_iam_role.ec2-s3-role-webserver.name
}
