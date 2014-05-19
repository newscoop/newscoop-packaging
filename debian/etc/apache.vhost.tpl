<VirtualHost *:80>
      ServerName __SERVER_NAME__
      #ServerAlias www.example.com

      ServerAdmin __SERVER_ADMIN__

      DocumentRoot /var/lib/newscoop
      DirectoryIndex index.php index.html
      Alias /javascript /var/lib/newscoop/javascript/

      <Directory /var/lib/newscoop>
              Options -Indexes +FollowSymLinks -MultiViews
              AllowOverride All
              #Uncomment the line below only for Apache 2.4 or later
              #Require all granted
      </Directory>
</VirtualHost> 
