#!/bin/bash
# User Data Script para Web Server com S3 Sync
set -e

# Log de execução
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "===== Iniciando User Data Script ====="
echo "Data: $(date)"

# Variável do bucket S3 (será substituída pelo Terraform)
S3_BUCKET="${bucket_name}"

# Atualizar sistema
echo "===== Atualizando sistema ====="
yum update -y

# Instalar nginx
echo "===== Instalando nginx ====="
yum install -y nginx

# Iniciar nginx
echo "===== Iniciando nginx ====="
systemctl start nginx
systemctl enable nginx

# Limpar pasta padrão
echo "===== Limpando pasta padrão ====="
rm -rf /usr/share/nginx/html/*

# Verificar se bucket está definido
if [ -z "$S3_BUCKET" ]; then
    echo "⚠️  Bucket S3 não definido, criando página padrão..."
    
    # Criar página HTML de teste
    cat > /usr/share/nginx/html/index.html << 'HTML'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Web Server AWS</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            text-align: center;
            padding: 2rem;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        h1 { margin: 0 0 1rem 0; font-size: 3rem; }
        .info {
            background: rgba(0, 0, 0, 0.2);
            padding: 1rem;
            border-radius: 5px;
            margin-top: 1rem;
        }
        .status { color: #4ade80; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Web Server Online!</h1>
        <p>Servidor: <strong>HOSTNAME_PLACEHOLDER</strong></p>
        <p>Availability Zone: <strong>AZ_PLACEHOLDER</strong></p>
        <div class="info">
            <p class="status">✅ Nginx configurado</p>
            <p class="status">✅ Health check OK</p>
            <p class="status">✅ Load Balancer ativo</p>
        </div>
    </div>
</body>
</html>
HTML

    # Substituir placeholders
    INSTANCE_ID=$(ec2-metadata --instance-id | cut -d " " -f 2)
    AZ=$(ec2-metadata --availability-zone | cut -d " " -f 2)
    
    sed -i "s/HOSTNAME_PLACEHOLDER/$INSTANCE_ID/g" /usr/share/nginx/html/index.html
    sed -i "s/AZ_PLACEHOLDER/$AZ/g" /usr/share/nginx/html/index.html
    
else
    echo "===== Baixando arquivos do S3: s3://$S3_BUCKET ====="
    
    # Aguardar um pouco para garantir que IAM Role está ativa
    sleep 10
    
    # Tentar baixar do S3
    if aws s3 sync s3://$S3_BUCKET/ /usr/share/nginx/html/ --delete; then
        echo "✅ Arquivos baixados do S3 com sucesso!"
    else
        echo "❌ Erro ao baixar do S3, criando página de erro..."
        
        # Criar página de erro se falhar
        cat > /usr/share/nginx/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Error - S3 Sync Failed</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: #ef4444;
            color: white;
        }
        .container { text-align: center; }
    </style>
</head>
<body>
    <div class="container">
        <h1>⚠️ Erro ao carregar conteúdo do S3</h1>
        <p>Verifique as permissões IAM e o bucket S3</p>
    </div>
</body>
</html>
HTML
    fi
    
    # Ajustar permissões
    chown -R nginx:nginx /usr/share/nginx/html
    chmod -R 755 /usr/share/nginx/html
fi

# Reiniciar nginx
echo "===== Reiniciando nginx ====="
systemctl restart nginx

# Verificar status
systemctl status nginx
netstat -tlnp | grep :80 || ss -tlnp | grep :80

echo "===== User Data Script concluído com sucesso! ====="
echo "Nginx está rodando na porta 80"
