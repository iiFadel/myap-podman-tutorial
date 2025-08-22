FROM registry.access.redhat.com/ubi9/httpd-24:1-321.1717085244

# Add application sources to the Apache document root
COPY index.html /var/www/html/
COPY community-logo.png /var/www/html/
COPY redhat-logo.png /var/www/html/
COPY README.md /var/www/html/

# The run script uses standard ways to run the application
CMD run-httpd