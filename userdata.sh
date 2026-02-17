user_data = <<-EOF
#!/bin/bash
yum update -y
yum install -y nginx aws-cli

systemctl start nginx
systemctl enable nginx

# limpar pasta padrão
rm -rf /usr/share/nginx/html/*

# baixar arquivos do S3
aws s3 cp s3://${aws_s3_bucket.website-project-matheus.bucket}/ /usr/share/nginx/html/ --recursive

# reiniciar nginx
systemctl restart nginx
EOF
