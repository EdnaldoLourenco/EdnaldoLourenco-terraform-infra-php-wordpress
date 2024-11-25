#!/bin/bash

# Verificar se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
    echo "Por favor, execute como root ou use sudo."
    exit
fi

echo "Atualizando e instalando pacotes necessários..."

sudo apt update && sudo apt upgrade -y


echo "Instalando Nginx..."
sudo add-apt-repository ppa:ondrej/nginx -y
sudo apt update
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
echo "Nginx instalado com sucesso!"


echo "Instalando PHP 8.3..."
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install -y php8.3-fpm php8.3-common php8.3-mysql \
php8.3-xml php8.3-intl php8.3-curl php8.3-gd \
php8.3-imagick php8.3-cli php8.3-dev php8.3-imap \
php8.3-mbstring php8.3-opcache php8.3-redis \
php8.3-soap php8.3-zip

sudo systemctl restart php8.3-fpm
echo "PHP 8.3 instalado com sucesso!"

# Configurar Nginx para WordPress
echo "Configurando Nginx para WordPress..."
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default

cat <<EOL | sudo tee /etc/nginx/sites-available/wordpress
server {
    listen 80;
    server_name your_server_ip;

    root /var/www/html/;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL

sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/wordpress
sudo systemctl restart nginx
echo "Nginx configurado para WordPress!"


echo "Instalando MySQL Client..."
sudo apt install mysql-client-core-8.0 -y
echo "MySQL Client instalado!"

# Criar banco de dados e usuário MySQL
DB_NAME="<dbname>"
DB_USER="<dbuser>"
DB_PASSWORD="<dbpass>"
DB_HOST="<dbhost>"

echo "Criando banco de dados e usuário no MySQL..."
mysql -h <dbhost> -u <user> -p'<password>' <<MYSQL_SCRIPT
CREATE DATABASE $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;
CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
echo "Banco de dados e usuário criados com sucesso!"

# Instalar WP-CLI e WordPress
echo "Instalando WP-CLI..."
cd ~/
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

echo "Baixando o WordPress..."
cd /var/www/html/
sudo wp core download --allow-root
echo "WordPress baixado!"

echo "Configurando o wp-config.php..."
cat <<EOL | sudo tee /var/www/html/wp-config.php
<?php
define('DB_NAME', '$DB_NAME');
define('DB_USER', '$DB_USER');
define('DB_PASSWORD', '$DB_PASSWORD');
define('DB_HOST', '$DB_HOST');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');
define('MYSQL_CLIENT_FLAGS', MYSQLI_CLIENT_SSL);

define( 'AUTH_KEY',         'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
define( 'NONCE_KEY',        'put your unique phrase here' );
define( 'AUTH_SALT',        'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
define( 'NONCE_SALT',       'put your unique phrase here' );


\$table_prefix = 'wp_';

define('WP_DEBUG', false);

if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';
EOL

echo "Configuração concluída!"

