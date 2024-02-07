# Imágenes de contenedor

Se identifican por:

    registry/repositorio:etiqueta

Muchas veces, nos olvidamos del registro... y que docker, crio, containerd...
el que sea que use, busque en los registros que tenga configurados por defecto.

Cuando uso regristro privados: En mi empresa genero mis imágenes... y las guardo en mi registro:
- Artifactory
- Nexus
- Gitlab Registry
- ...

La etiqueta lleva información variada. Solemos encontrar:
- información de la versión del software
    latest
    1.2.3
    1.2
    1
- información de la imagen base que se ha utilziado para montar la imagen
    alpine
    ubuntu
    debian
    fedora
- información de otro software adional que viene
    httpd:1.4-perl
- características de la inftalación concretas
    wordpress:6.4-fpm (soporte de fgactCGI)

"LATEST" no es una palabra mágica que existe en el mundo de la contenedorización.
Qué significa "latest" y cómo se trata? IGUAL QUE CUALQUIER OTRO TAG.
Si yo no pongo nada en la etiqueta al identificar una imagen, 
los gestores de contenedores buscan el tag "latest", que puede existir o no.
Depende de si los desarrolladores lo han creado.

Muchos desarrolladores no crean tag latest... DE HECHO SU USO ES UNA MUY MUY MUY MALA PRACTICA 

# Versiones de software

    a.b.c

                Cuando se suben?
    a: MAJOR    Breaking changes: Cambios que no garantizan RETROCOMPATIBILIDAD
    b: MINOR    Nueva funcionalidad
                Funcionalidad marcada como deprecated
                    + opcionalmente pueden venir arreglos de bugs
    c: PATCH    Arreglo de bugs

En los entornos de producción, al elegir la imagen de un contenedor nos gustan cosas como:
    latest      ESTA NUNCA: No tengo npi de que se está instalando. Hoy puede ser la 1.2.3 y mañana la 2.7.8
    1.2.3       Y esta poco / a veces.
                Ésta siempre es fija... apunta a la misma en el tiempo.. ME DA CONTROL
                Pero quizás hay una versión que resuelve más bugs, dandome la funcionalidad que necesito
    1.2         Esta nos encanta. El minor me garantiza la funcionalidad que necesito.
                Este tag hoy puede ser el 1.2.3 y mañana el 1.2.10
                GUAY , dame la última versión que tenga mi funcionalidad que necesito, 
                       pero con la mayor cantidad posible de bugs arreglados
    1           ESTA TAMPOCO... 
                Hoy puede apuntar a la 8.1.4 y mañana a la 8.6.8
                Lo que implica que: Tiene la funcionalidad que necesito... 
                pero puede que más (nuevas funcionaldiad que no necesito) que vengan con nuevos bugs
                
# Configmap y Secrets

Para qué sirven los configmap y los secrets:
- Para alimentar variables de entorno de nuestros pods
- Inyectar ficheros de configuración a los contenedores

Ventajas de usar configmaps y secrets:
- Evito duplicidad... Los datos de 1 configmap los puedo usar en 50 sitios.
- Separo la definición del despliegue de los datos concretos.
    El despliegue que estamos haciendo de WP, solo lo quiero hacer en un entorno? PRODUCCION / PRUEBAS / DESARROLLO
    En todos los entornos tendrá las mismas contraseñas, nombres de usuario... etc? NO
    Quiero cambiar el Deployment entre ENTORNOS? NO
    Lo que tendré es en cada entorno su propio CONFIGMAP... y un único deployment
        - Quién configura el archivo de DEPLOYMENT / Quién lo escribe? DESARROLLO   \
        - Quién escribe el configMap? QUIEN GESTIONE EL ENTORNO DE PRODUCCION       / Separación de responsabilidades
    1 archivo con el deployment
    3 archivos:
            configmap-desarrollo.yaml
            configmap-pruebas.yaml
            configmap-produccion.yaml

## Sobre secrets

Lo único que me garantizan los secrets es que dentro de la BBDD de kubernetes se guardan encriptados sus valores.
Más me vale a mi tener cuado con los ficheros de definición de secrets... donde los pongo y quién tiene acceso.

Alternativa:

    $  kubectl create secret generic MISECRETO -n MINS --from-literal=VARIABLE=VALOR --from-literal=VARIABLE2=VALOR2
    kubectl create secret generic MISECRETO -n ivan --from-literal=VARIABLE=VALOR --from-literal=VARIABLE2=VALOR2

Nota:
    
    En la práctica NUNCA ESCRIBIMOS FICHEROS DE MANIFIESTO, como lo estamos haciendo en el curso,
    por lo que esto no supone un problema.
    
# Volumenes

> Para qué sirven los volumenes?

- Persistencia de información tras el borrado de un contenedor
  Compartir información entre contenedores de distintos pods (que pueden estar en distintas máquinas):


    docker container create -v ALGO:ALGO2
    docker-compose
        volumes:
            - ALGO:ALGO2
        ALGO2: Ruta en el contenedor (Punto de montaje en el FS del contenedor que apunta a)
        ALGO:  Ruta en el host
    Esto no vale para persitencia en un entorno de PRODUCCION (en uno de juguete, como os creamos con docker si)
    Por qué?
        Si el host se jode... en kubernetes puedo mover el pod a otra máquina (lo borro y creo uno nuevo en otra máquina... lo hace kubernetes)
        Y ... los datos? si estaban en ese host... JODIDO VOY
    En un entorno de producción los datos no se pueden guardar a nivel de host. NO VALE.
    Los tengo que guardar en un almacenamiento EXTERNO, accesible por red.
    
        Carpetas nfs compartidas en red
        iscsi
        cabinas de almacenamiento: por fibra 
        volumen en AWS, GCP, AZURE, IBM cloud...

+ Compartir información entre contenedores del mismo pod
    emptyDir: Carpeta vacía a nivel del host.
+ Inyectar ficheros de configuración a los contenedores 
    - configMap
    - secret
    - emptyDir / initContainer
+ Hacer disponible a un contenedor ficheros/carpetas del host
    En un SO Linux, un fichero es un concepto MUY POTENTE:
    - Los procesos tienen un mapeo como ficheros
    - Un socket de escritua a un demonio tiene un mapeo como fichero
    - DiD: Docker in Docker: Hacer que un contenedor pueda crear nuevos contenedores:
        - Inyecto a un contenedor el comando docker
        - Y le inyecto el socket del demonio de docker.
    hostPath (Lo más parecido a los volumenes de docker a los que estamos acostumbrados... y que en kubernetes valen solo para casos MUY MUY RAROS: DiD, Monitorización del host)

En kubernetes tenemos un huevo de tipos de volumenes... en función del uso que necesite

Los volumenes se definen a nivel de POD... y se MONTAN a nivel de CONTENEDOR

Tenemos 2 problemas al usar volumenes para persietncia de datos:
 - En cuantos entornos/namespaces querré desplegar este pod? en 1? PROD/TEST/DEVELOP...
     Y en todos se van a guardar los datos en el mismo volumen? NI DE COÑA !
     Y entonces necesito 3 archivos de despliegue? El mnto sería una locura
 - Quién escribe este fichero? el pod? el deployment(pod template)? DESARROLLO
    Y yo, oh DESARROLLADOR, tengo que saber en que puñetera LUN de una cabina de fibra se guardan los datos? EIN? 
    O el id de un volumen en AMAZON ? EIN?

Qué se yo, oh persona que quiere despleguar su app en un entorno de producción o desarrollo... con respecto al almacenamiento?
- Cuanto espacio quieres ?
- Tipo de almacenamiento ? Rapidito / Redundante -> PRODUCCION ... desarrollo: Lentito / No redundante / encriptado

Esto es lo que resuelven los:

# PV, PVC

# Qué es un PVC?

Es una especificación del tipo de volumen que necesito... en mi lenguaje de desarrollador o de tio que quiere una app en un entorno.
El PVC lo crea DESARROLLO

# Qué es un PV?

Una REFERENCIA a un volumen que existe por ahñi en algún sitio + junto con una espeficicación de ese volumen.
El PV lo crea Administrración del cluster de kubernetes (los que administran el entorno de producción)

DE NUEVO TENEMOS UNA SEPARACION DE RESPONSABILIDADES en kubernetes.

El volumen y la petición de volumen se crean de forma totalmente independientes.
En un cluster, tendré:
- 50 volumenes creados por los sysadmins        CHICOS
- 37 peticiones hechas por desarrolladores      CHICAS 

Se van registrando cosillas por allí.
Y esto es como si me registro en TINDER !

Y el kubernetes hace MATCH !
Mira si hay chicos con características "COMPATIBLES" con las chicas ;)
Pa' que surja el amor...o el folleteo!

ADMIN:                                          DATOS REALES DEL VOLUMEN PRECREADO
    NFS
    storageClassName: rapidito-redundante   √
    capacity: 
        storage: 10Gi                       √
    accessModes:
        - ReadWriteOnce                     √
        - ReadWriteMany
        - ReadOnlyMany
DESARROLLADOR                                   CARTA A LOS REYES MAGOS ... quiero !
    storageClassName: rapidito-redundante   √
    resources:
        requests: 
            storage: 5Gi                    √
    accessModes:
        - ReadWriteOnce                     √
        
Y KUBERNETE SCREA EL AMOR <3           >

Hace 8 años, los administradores de sistemas que operaban un cluster de kubernetes, creaban de antemano 50 volumenes donde fueran...
Y los registraban en kubernetes....
Y los desarrolladores iban haciendo sus pvcs... y los iban consumiendo

Hoy en dia, montamos PROVISIONADORES AUTOMATIZADOS DE VOLUMENES, que son programas que:
- Cuando un desarrollador solicita un PVC
- Van Donde sea a CREAR automáticamente el volumen (CABINA, AWS, NFS)
- Y registran ese volumen en kubernetes...
- Y PIDEN a kubernetes que ese volumen sea asignado a la PVC que atendieron.

De esos programas puedo tener 5 montados. Cada uno atendiendo a un determinado STORAGE CLASS
De forma que cuando alguien pide un volumen REDUNDANTE, tendre un programa que lo cree en un determinado backend
Mientras que cuando alguien pide un volumen CIFRADO, tendré otro programa que lo cree en otro determinado backend

Los desarrolladores lo que saben son los STORAGE CLASS disponibles ... los tipos de almacenamiento que pueden pedir.
---
# Qué se entiende por el log de un contenedor

La salida estandar y de error del proceso principal (el comando) que ejecuta el contenedor