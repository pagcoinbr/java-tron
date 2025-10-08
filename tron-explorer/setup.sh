#!/bin/bash

# TRON Explorer Setup Script
# This script sets up Apache to serve the TRON Explorer locally

echo "🚀 Setting up TRON Explorer with Apache..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run this script with sudo privileges"
    echo "Usage: sudo ./setup.sh"
    exit 1
fi

# Update system packages
echo "📦 Updating system packages..."
apt update

# Install Apache if not installed
if ! command -v apache2 &> /dev/null; then
    echo "📦 Installing Apache2..."
    apt install -y apache2
else
    echo "✅ Apache2 is already installed"
fi

# Enable required Apache modules
echo "🔧 Enabling Apache modules..."
a2enmod rewrite
a2enmod headers
a2enmod deflate
a2enmod expires

# Copy virtual host configuration
EXPLORER_DIR="/home/pagcoin/java-tron/tron-explorer"
APACHE_SITES_DIR="/etc/apache2/sites-available"
SITE_CONFIG="tron-explorer.conf"

echo "📝 Setting up virtual host..."

# Create the virtual host configuration
cat > "$APACHE_SITES_DIR/$SITE_CONFIG" << EOF
<VirtualHost *:80>
    ServerName tron-explorer.local
    DocumentRoot $EXPLORER_DIR
    
    # Enable CORS for API calls
    Header always set Access-Control-Allow-Origin "*"
    Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Header always set Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With"
    
    # Handle preflight requests
    RewriteEngine On
    RewriteCond %{REQUEST_METHOD} OPTIONS
    RewriteRule ^(.*)$ \$1 [R=200,L]
    
    <Directory $EXPLORER_DIR>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
        
        # Enable compression for better performance
        <IfModule mod_deflate.c>
            AddOutputFilterByType DEFLATE text/plain
            AddOutputFilterByType DEFLATE text/html
            AddOutputFilterByType DEFLATE text/xml
            AddOutputFilterByType DEFLATE text/css
            AddOutputFilterByType DEFLATE application/xml
            AddOutputFilterByType DEFLATE application/xhtml+xml
            AddOutputFilterByType DEFLATE application/rss+xml
            AddOutputFilterByType DEFLATE application/javascript
            AddOutputFilterByType DEFLATE application/x-javascript
        </IfModule>
        
        # Cache static files
        <IfModule mod_expires.c>
            ExpiresActive on
            ExpiresByType text/css "access plus 1 year"
            ExpiresByType application/javascript "access plus 1 year"
            ExpiresByType image/png "access plus 1 year"
            ExpiresByType image/jpg "access plus 1 year"
            ExpiresByType image/jpeg "access plus 1 year"
        </IfModule>
    </Directory>
    
    # Logging
    ErrorLog \${APACHE_LOG_DIR}/tron-explorer_error.log
    CustomLog \${APACHE_LOG_DIR}/tron-explorer_access.log combined
</VirtualHost>
EOF

# Set proper permissions
echo "🔐 Setting proper permissions..."
chown -R www-data:www-data "$EXPLORER_DIR"
chmod -R 755 "$EXPLORER_DIR"

# Enable the site
echo "🌐 Enabling the site..."
a2ensite tron-explorer.conf

# Disable default Apache site to avoid conflicts
a2dissite 000-default.conf 2>/dev/null || true

# Add entry to hosts file if not exists
HOSTS_ENTRY="127.0.0.1 tron-explorer.local"
if ! grep -q "tron-explorer.local" /etc/hosts; then
    echo "📝 Adding entry to /etc/hosts..."
    echo "$HOSTS_ENTRY" >> /etc/hosts
fi

# Test Apache configuration
echo "🔍 Testing Apache configuration..."
if apache2ctl configtest; then
    echo "✅ Apache configuration is valid"
    
    # Restart Apache
    echo "🔄 Restarting Apache..."
    systemctl restart apache2
    systemctl enable apache2
    
    echo ""
    echo "🎉 TRON Explorer setup completed successfully!"
    echo ""
    echo "📋 Access Information:"
    echo "   🌐 URL: http://tron-explorer.local"
    echo "   🌐 Alternative: http://localhost"
    echo "   📁 Directory: $EXPLORER_DIR"
    echo ""
    echo "📝 Important Notes:"
    echo "   1. Make sure your TRON node is running on ports 8090, 8091, 8092"
    echo "   2. Your wallet seed phrases are encrypted and stored locally in browser"
    echo "   3. Never share your seed phrase with anyone"
    echo "   4. This is for local development/testing only"
    echo ""
    echo "🚀 You can now open http://tron-explorer.local in your browser!"
    
else
    echo "❌ Apache configuration test failed. Please check the configuration."
    exit 1
fi