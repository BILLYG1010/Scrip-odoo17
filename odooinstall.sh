#!/bin/bash

# Creamos el usuario y grupo de sistema 'odoo':
sudo adduser --system --quiet --shell=/bin/bash --home=/opt/odoo --gecos 'odoo' --group odoo

# Creamos en directorio en donde se almacenará el archivo de configuración y log de odoo:
sudo mkdir /etc/odoo && sudo mkdir /var/log/odoo/

# Instalamos Postgres y librerías base del sistema:
sudo apt update
sudo apt install postgresql postgresql-server-dev-15 git python3 python3-pip build-essential python3-dev libldap2-dev libsasl2-dev python3-setuptools libjpeg-dev nodejs npm -y

# Descargamos odoo version 17 desde git:
sudo git clone --depth 1 --branch 17.0 https://github.com/odoo/odoo /opt/odoo/odoo

# Damos permiso al directorio que contiene los archivos de OdooERP e instalamos las dependencias de python3:
sudo chown odoo:odoo /opt/odoo/ -R && sudo chown odoo:odoo /var/log/odoo/ -R
sudo pip3 install -r /opt/odoo/odoo/requirements.txt

# Descargamos dependencias e instalar wkhtmltopdf para generar PDF en odoo:
sudo apt install fontconfig xfonts-base xfonts-75dpi -y
cd /tmp
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb && sudo dpkg -i wkhtmltox_0.12.6.1-3.jammy_amd64.deb
sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin/ && sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin/

# Creamos un usuario 'odoo' para la base de datos:
sudo -u postgres createuser -s odoo

# Creamos la configuracion de Odoo:
sudo su - odoo -c "/opt/odoo/odoo/odoo-bin --addons-path=/opt/odoo/odoo/addons -s --stop-after-init"

# Creamos el archivo de configuracion de odoo:
sudo mv /opt/odoo/.odoorc /etc/odoo/odoo.conf

# Agregamos los siguientes parámetros al archivo de configuración de odoo:
sudo sed -i "s,^\(logfile = \).*,\1/var/log/odoo/odoo-server.log," /etc/odoo/odoo.conf

# Creamos el archivo de inicio del servicio de Odoo:
sudo cp /opt/odoo/odoo/debian/init /etc/init.d/odoo && sudo chmod +x /etc/init.d/odoo
sudo ln -s /opt/odoo/odoo/odoo-bin /usr/bin/odoo

# Creamos un archivo de servicio systemd para Odoo
sudo tee /etc/systemd/system/odoo.service > /dev/null <<EOF
[Unit]
Description=Odoo
After=network.target

[Service]
Type=simple
User=odoo
Group=odoo
ExecStart=/usr/bin/odoo --config /etc/odoo/odoo.conf
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
EOF

# Habilitamos y iniciamos el servicio de Odoo
sudo systemctl daemon-reload
sudo systemctl enable odoo
sudo systemctl start odoo