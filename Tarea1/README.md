# Grupo Linux

### Tarea 1 (Scripts)

- **switch_module.sh**: Script que permite activar y desactivar un modulo del kernel. El script recibe como parametro el nombre del modulo a activar o desactivar. Si el modulo esta activado, lo desactiva y viceversa.
- **references_list.sh**: Script que guarda en un archivo las referencias de los archivos seleccionados. El script recibe como parametro el nombre del archivo donde se guardaran las referencias y las acciones a realizar. Las acciones pueden ser: -a para agregar referencias, -d para eliminar referencias y -s para listar las referencias (En caso de listar las referencias, no hay que pasar el nombre del archivo donde se guardaran las referencias).
- **usb_log.sh**: Script que guarda en un archivo las acciones realizadas sobre los dispositivos usb. Se usa en conjunto con el demonio udev. El script revisa los estados de los dispositivos usb y guarda en un archivo las acciones realizadas sobre estos.

