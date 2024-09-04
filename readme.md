# Instalación de Odoo 17 en Ubuntu 22.04

Siga estos pasos para instalar Odoo en su sistema:

## Paso 1: Crear el archivo de instalación

Abra una terminal y ejecute el siguiente comando para crear un nuevo archivo llamado `odooinstall.sh`:

```
sudo nano odooinstall.sh
```

## Paso 2: Copiar el script de instalación

Copie el contenido del archivo `odooinstall.sh` proporcionado en el nuevo archivo que acaba de crear. Asegúrese de pegar todo el contenido correctamente.

## Paso 3: Dar permisos de ejecución

Una vez que haya guardado el archivo, otórguele permisos de ejecución con el siguiente comando:

```
sudo chmod u+x odooinstall.sh
```

## Paso 4: Ejecutar el script de instalación

Ejecute el script de instalación con el siguiente comando:

```
sudo sh odooinstall.sh
```

Espere a que el script complete la instalación.

## Paso 5: Acceder a Odoo

Una vez finalizada la instalación, abra un navegador web y acceda a Odoo utilizando la siguiente URL:

```
http://IP:8069
```

Reemplace "IP" con la dirección IP de su servidor.

¡Felicidades! Ahora debería tener Odoo instalado y funcionando en su sistema.
