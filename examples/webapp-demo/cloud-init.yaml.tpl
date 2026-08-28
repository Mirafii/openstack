#cloud-config
package_update: true
packages:
  - nginx

write_files:
  - path: /var/www/html/index.html
    permissions: '0644'
    owner: root:root
    content: |
      ${indent(6, index_html)}

runcmd:
  - systemctl enable nginx
  - systemctl restart nginx
