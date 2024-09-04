#!/bin/bash

# Step 1: Actualizar y mejorar los paquetes del sistema
sudo apt update && sudo apt upgrade -y
echo "Paso 1 completado: Sistema actualizado y mejorado."

# Step 2: Instalar PostgreSQL
sudo apt-get install postgresql -y
echo "Paso 2 completado: PostgreSQL instalado."

# Step 3: Crear un usuario de PostgreSQL llamado odoo17 con privilegios de superusuario
sudo su - postgres -c "createuser -s odoo17" 2> /dev/null || true
echo "Paso 3 completado: Usuario PostgreSQL odoo17 creado."

# Step 4: Establecer una contraseña para el usuario odoo17
sudo -u postgres psql -c "ALTER USER odoo17 PASSWORD 'odoo';" 2> /dev/null || true
echo "Paso 4 completado: Contraseña para odoo17 establecida."

# Step 5: Crear un usuario del sistema para Odoo y agregarlo al grupo sudo
sudo adduser --system --quiet --shell=/bin/bash --home=/opt/odoo --gecos 'ODOO' --group odoo
sudo adduser odoo sudo
echo "Paso 5 completado: Usuario del sistema odoo creado y agregado al grupo sudo."

# Step 6: Instalar las dependencias requeridas
sudo apt-get install git python3 python3-pip build-essential wget python3-dev python3-venv python3-wheel libxslt-dev libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less libjpeg-dev gdebi -y
sudo apt-get install libpq-dev python3-dev libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev libffi-dev python3-psutil python3-polib python3-dateutil python3-decorator python3-lxml python3-reportlab python3-pil python3-passlib python3-werkzeug python3-psycopg2 python3-pypdf2 python3-gevent -y
echo "Paso 6 completado: Dependencias requeridas instaladas."

# Step 7: Instalar wkhtmltopdf
sudo wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb
sudo apt install ./wkhtmltox_0.12.6.1-2.jammy_amd64.deb -y
echo "Paso 7 completado: wkhtmltopdf instalado."

# Step 8: Crear un directorio de logs para Odoo
sudo mkdir /var/log/odoo
sudo chown odoo:odoo /var/log/odoo
echo "Paso 8 completado: Directorio de logs creado y permisos establecidos."

# Step 9: Clonar el repositorio de Odoo17
sudo git clone --depth 1 --branch 17.0 https://github.com/odoo/odoo /opt/odoo/server-code
sudo chown -R odoo:odoo /opt/odoo
echo "Paso 9 completado: Repositorio de Odoo17 clonado."

# Step 10: Crear un archivo de configuración para Odoo
cat <<EOF | sudo tee /etc/odoo17.conf
[options]
admin_passwd = PASSWORD
db_host = localhost
db_user = odoo17
db_password = odoo
http_port = 8069
logfile = /var/log/odoo/odoo17-server.log
data_dir = /opt/odoo/.local/share/Odoo
addons_path = /opt/odoo/server-code/addons
EOF
echo "Paso 10 completado: Archivo de configuración de Odoo creado."

# Step 11: Cambiar la propiedad y permisos del archivo de configuración
sudo chown odoo:odoo /etc/odoo17.conf
sudo chmod 640 /etc/odoo17.conf
echo "Paso 11 completado: Propiedad y permisos del archivo de configuración cambiados."

# Step 12: Crear y activar un entorno virtual para Odoo
sudo -u odoo python3 -m venv /opt/odoo/odoo-venv
source /opt/odoo/odoo-venv/bin/activate
echo "Paso 12 completado: Entorno virtual creado y activado."

# Step 13: Instalar los paquetes Python requeridos
pip install wheel
pip install -r /opt/odoo/server-code/requirements.txt
echo "Paso 13 completado: Paquetes Python requeridos instalados."

# Step 14: Desactivar el entorno virtual
deactivate
echo "Paso 14 completado: Entorno virtual desactivado."

# Step 15: Crear un servicio systemd para Odoo
cat <<EOF | sudo tee /etc/systemd/system/odoo17.service
[Unit]
Description=Odoo17
Requires=postgresql.service
After=network.target postgresql.service

[Service]
Type=simple
SyslogIdentifier=odoo
PermissionsStartOnly=true
User=odoo
Group=odoo
ExecStart=/opt/odoo/odoo-venv/bin/python3.12 /opt/odoo/server-code/odoo-bin -c /etc/odoo17.conf
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
EOF
echo "Paso 15 completado: Servicio systemd para Odoo creado."

# Step 16: Cambiar la propiedad y permisos del archivo del servicio
sudo chmod 755 /etc/systemd/system/odoo17.service
sudo chown root: /etc/systemd/system/odoo17.service
echo "Paso 16 completado: Propiedad y permisos del archivo del servicio cambiados."

# Step 17: Comandos del servicio
sudo systemctl start odoo17.service
sudo systemctl status odoo17.service
sudo systemctl restart odoo17.service
sudo systemctl daemon-reload
echo "Paso 17 completado: Comandos del servicio ejecutados."

# Step 18: Habilitar el servicio de Odoo en el inicio del sistema
sudo systemctl enable odoo17.service
echo "Paso 18 completado: Servicio de Odoo habilitado en el inicio del sistema."
