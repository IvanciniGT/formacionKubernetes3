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
