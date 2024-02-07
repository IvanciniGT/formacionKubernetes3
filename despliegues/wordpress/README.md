# Wordpress

Es un programa desarrollado en php, que corre sobre un servidor web (APACHE, nginx)
Necesita de una BBDD (MySQL/MariaDB)

## Cosas que ya sabemos hacer

- Crear una plantilla de pod para WP
- Crear una plantilla de pod para MariaDB

Tanto los pods creados desde una plantilla como desde la otra, se montarán con un contenedor, generado desde una IMAGEN de contenedor:
- MARIADB
- WP(Apache)

Ambas imágenes de contenedor admiten cierta parametrización (vía variables de entorno)... y eso ya sabemos también especificarlo.

Podríamos usar un Deployment para definir cada plantilla.
(NOTA: por ahora me vale... más adelante os contaré que para el MariaDB, lo suyo es definir un Statefulset, y no un Deployment.)

## Problemas (cosas que NO sabemos hacer aún)

- Persistencia de la información (VOLUMENES)
- Comunicación del Apache/WP con el MariaDB
    config.php (ENV) ---> db_host: ??? IP del POD de MariaDB
    PERO Esa solución sería un DESASTRE ENORME !!!!!
    1º No conozco a priori esa IP
    2º Siempre va a tener la misma IP el mariaDB (la mantiene a lo largo del tiempo?)
        NO... en cuantito (y lo hará) el kubernetes decida que ese POD quiere:
            - Reiniciarlo porque se ha quedado crujido
            - Moverlo a otra máquina... que esa está petada
        Realmente lo que hará kubernetes es borrar el pod y crear uno nuevo, con los mismo datos...
            PERO con una IP diferente... Y esto haría que nuestro WP dejase de funcionar !
- Montado todo... Cómo llego al WP? que url pongo en mi navegador?
        http://IP_DEL_POD_WP:80 ??? Desde luego desde mi casa no... Mi ordenador de mi casa no está en la misma red que el POD de WP... es imposible que acceda a esa IP.   