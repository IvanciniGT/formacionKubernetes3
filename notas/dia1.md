# Tipos de Software

Hay un huevo de tipos de software:
- Sistema operativo (No es contenedorizable: Dentro de un contenedor no puedo ejecutar un SO)
- Driver
- Aplicación
- Demonio
  - Servicio
- Script
- Comando
- Biblioteca
- ...

Algunos de esos tipos de software cuando se ejecutan dan lugar a un proceso (aplicación, demonio, servicio, script, comando)... otros a varios (SO, aplicaciones).. y otros se ejecutan dentro de un proceso creado por otro software (librería).

# Linux

Linux NO ES un Sistema operativo.
Linux es un kernel de SO.
Un SO no es un programa único... es toda una colección de programas enlatados:
- Windows
- Ubuntu
- MacOS
Un SO tiene siempre un Kernel... que es la parte de ese SO que se encarga (entre otros):
- Interactuar / gestionar el HW de la máquina
- Controlar los procesos que se ejecutan en la máquina
Los SO llevan otro montón de mierdas:
- Administrador de paquetes (para instalaciones: WINDOWS (tienda de microsoft + chocolate, MACOS: Tienda de apple + brew, UBUNTU/DEBIAN: apt, RHEL: yum)
- Administrador de archivos (gráficos y no gráficos)
- Administrador de usuarios
- Administrador de red
- Administrador de procesos

El SO que habitualmente usamos en servidores en empresas se llama GNU/Linux. Este SO se ofrece mediante distribuciones. Las distribuciones llevan el kernel de Linux, un huevo de herramientas de GNU... y aderezos propios de cada distribución (apt, yum, dnf... gnome, kde)
Android es un SO que tiene dentro el kernel linux... aunque no lleva ninguna de las herramientas de GNU... en su ligar, lleva otras creadas por la gente de google.

## Qué era UNIX? 

Unix era un SO que se desarrolló en los 70 en los laboratorios Bell de AT&T. Era un SO que se desarrolló para ser multiusuario y multitarea. Era un SO que se desarrolló para ser usado en servidores. Era un SO que se desarrolló para ser usado en entornos de producción.
Se dejó de hacer a principios de los 2000.

De UNIX, cuando existía surgieron más de 400 versiones paralelas... Los fabricantes de HW (Commodore, Atari, Olivetti, IBM, HP, SUN, SGI, DEC, etc) tenían su propia versión adaptada de UNIX. Muchas de esas versiones de UNIX presentaban incompatibilidades entre ellas. Es decir, había programas que se ejecutaban en una versión de UNIX que no se ejecutaban en otra versión de UNIX.

Para poner coherencia surgieron 2 estándares: POSIX y SUS(Single UNIX Specification). Estos estándares definían cómo debía evolucionar un SO para que se le pudiera llamar UNIX.

## Qué es UNIX?

Hoy en día UNIX son esos estándares (POSIX y SUS) y los SO que los cumplen decimos que son SO certificados UNIX(HP-UX, AIX, Solaris, MacOS).
Linux no es un SO Unix... Se parece muchos... quizás cumpla con esas especificaciones... ni lo sabemos ni nos importa.

## Qué es POSIX?

Define un montón de aspectos que debe cumplir el SO, para ser considerado UNIX. Entre ellos:
- Estructura de directorios
  /
    bin/
    opt/
    var/
    etc/
    home/
    root/
    ...
- Asignación de permisos
- Algunos comandos básicos para interactuar con el kernel (mv, cp, mkdir, sh, cat, ls, ps, kill, ...)


# Contenedores

## Qué es un contenedor?

Entorno aislado que puedo crear dentro de un kernel Linux (por cómo está montado Linux... y el API que ofrece), donde ejecutamos procesos.
Aislado:
- Su propio sistema de archivos
- Sus propias variables de entorno
- Su propia configuración de red -> Sus propias IPs
- Puede tener una limitación de acceso a los recursos físicos (RAM, CPU, Almacenamiento) del host.

La diferencia clave entre contenedores y máquinas virtuales es que dentro de un contenedor no puedo ejecutar un sistema Operativo, tal y como se hace en una máquina virtual.

En su lugar, es el Kernel del SO del host el que controla los recursos/procesos que se usan/corren dentro del contenedor.

Aquí solo hay un SO... y es el del host.

Los contenedores los generamos desde imágenes de contenedor.

Para crear y gestionar contenedores, usamos GESTORES de contenedores (DOCKER, CRIO, CONTAINERD, PODMAN....)

## Qué es una imagen de contenedor?

Un triste fichero comprimido (en lugar de zip, se usa tar.gz) que contiene dentro un conjunto de carpetas (habitualmente compatible/según el estándar POSIX) y un software (o varios) y todo lo necesario para que ese software se ejecute.... lo cual puede implicar adicionalmente:
- Otros programas (librerías, demonios, servicios, comandos, scripts)
- Configuraciones
- Datos
- ...

Las usamos por ejemplo para empaquetar y distribuir una aplicación / O un comando / O un servicio(API REST).

En una imagen de contenedor NO es posible meter un SO.

Las imágenes las descargamos, las descomprimimos, y las usamos para crear contenedores .

En la estructura de carpetas que viene dentro de una imagen de contenedor (archivo comprimido) encontramos programa PREINSTALADOS por alguien.
En muchas ocasiones, me interesa que en ese archivo comprimido (imagen de contenedor) vengan programas adicionales que me interesen a mi:
- cp
- bash
- apt/yum/dnf
- ...

Cuando creamos imágenes de contenedor, partimos de una imagen base (que ya tiene dentro una estructura de carpetas compatible con POSIX, y conjunto de programas básicos que me puedan venir bien)... y luego yo le pongo el reto de cosas que me interesen.

Cuando me descargo la imagen ALPINE, lo que encuentro dentro es:
- Las carpetas básicas de un SO POSIX
- Y los 4 comandos básicos de linux (sh, cp, mv, ls, cat, head, tail...)... que en total ocupan 3 Mbs
  
Cuando me descargo una imagen UBUNTU, lo que encuentro dentro es:
- Las carpetas básicas de un SO POSIX
- Los 4 comandos básicos de linux (sh, cp, mv, ls, cat, head, tail...)
- Y algunos más: bash, apt, dpkg, ...

Cuando me descargo una imagen de FEDORA, lo que encuentro dentro es:
- Las carpetas básicas de un SO POSIX
- Los 4 comandos básicos de linux (sh, cp, mv, ls, cat, head, tail...)
- Y algunos más: bash, dnf, rpm, ...

# Kubernetes

## Qué es Kubernetes?

Kubernetes no es un gestor de contenedores... ni un orquestador de contenedores... ni un orquestador de imágenes de contenedores.

Es un Orquestador de gestores de contenedores apto para entornos de producción.
Permite hacer despliegues de software contenedorizado con HA y escalabilidad (las 2 características más importantes de un entorno en producción).

Cluster de máquinas:
    - Máquina 1
      - Un gestor de contenedores (Crio o ContainerD)
    - Máquina 2
      - Un gestor de contenedores (Crio o ContainerD)
    - ...
    - Máquina N
      - Un gestor de contenedores (Crio o ContainerD)
Esos gestores de contenedores, van a estar operados por Kubernetes... No como cuando trabajo con Docker, que soy a manita quién crea, para, reinicia contenedores. En el caso de usar kubernetes, es kubernetes quien se encarga de eso.
Kubernetes pide a los gestores de contenedores de cada máquina que:
- Creen un contenedor
- Borren un contenedor
- Reinicien un contenedor
- Los logs de un contenedor

Kubernetes, me permitirá hablar con él (con kubernetes) para usando un lenguaje DECLARATIVO, indicarle cómo quiero configurado mi entorno de producción:
- Cluster de aplicaciones...
- Volumenes de almacenamiento
- Balanceadores de carga
- Proxies reversos
- Reglas de firewall de red

Qué podemos decir de kubernetes:
x Orquestador de imágenes de contenedores ( los gestores de contenedores son los que usan imágenes)
√ Orquestador de despliegues. Él se encarga de hacer despliegues de apps.
x Implementar una arquitectura en cloud. Es decir:
  Para ejecutar kubernetes necesito una serie de máquinas conectadas entre si mediante una RED... Esas máquinas las puedo comprar e instalar inhouse (on premisses) o puedo rentarlas a un cloud... lo que me interese...
  Incluso puedo pedirle a un cloud que me genere él una instalación de kubernetes en sus máquinas... y me quito ese trabajo adicional.
√ Me permite conseguir Alta disponibilidad y Escalabilidad de mis apps, características claves de un entorno de producción.
    - Alta disponibilidad: Tratar de asegurar un determinado tiempo de servicio de mis aplicaciones.
    - Escalabilidad: Ajustar la infra/procesos para adaptarse a la demanda de mis aplicaciones en cada momento.
x Administrador de aplicaciones contenedorizadas... Me permite configurar los despliegues de esas aplicaciones y mantener esa configuración en el tiempo... pero no me permite configurar las aplicaciones en sí.

A Kubernetes SOLO le doy configuraciones... Él se encarga de ejecutar los trabajos.
Esas configuraciones las hacemos en ficheros YAML habitualmente (hay otras formas... poco utilizadas, salvo gloriosas excepciones)

En esos ficheros configuraremos distintos tipos de OBJETOS de kubernetes:
- NODE
* NAMESPACE
* POD
* DEPLOYMENT
* STATEFULSET
* DAEMONSET
* JOB
* CRONJOB
- CONFIGMAP
- SECRET
- PERSISTENTVOLUMEN
- PERSISTENTVOLUMENCLAIM
- SERVICE
- INGRESS
- NETWORKPOLICY
- LIMITRANGE
- RESOURCEQUOTA
- SERVICEACCOUNT

El despliegue de un software dentro de kubernetes, implica la creación de un montón de esos objetos.
Nuestro objetivo en el curso:
- Por un lado aprender a instalar un cluster de kubernetes  ---> Entender la arquitectura de un cluster de kubernetes.
- Por otro lado, queremos aprender qué son esos Objetos, cómo definirlos y para qué los usamos.
- Además, queremos entender:
  - cómo se gestiona/configura el aprovisionamiento de volúmenes dentro de un cluster: PV, PVC
  - cómo se realizan las comunicaciones entre los distintos objetos de un cluster de kubernetes: SERVICE, INGRESS, NETWORKPOLICY
- Por último, vamos a conocer cuales son los procedimientos más estándar para desplegar aplicaciones en kubernetes (HELM)

Kubernetes es usado por distintos perfiles:
- Desarrollares que quieren desplegar sus apps con HA / Escalabilidad
- Operadores que irán monitorizando / haciendo alguna operación básica sobre el software que tenga desplegado en kubernetes
- Administradores de sistemas que van a velar por el correcto desempeño de kubernetes (habiéndolo instalado y configurado de antemano)

Cada uno de esos perfiles necesita un conocimiento más especializado de la herramienta.

En esta formación damos una introducción al mundo de kubernetes... que sirve para todos esos perfiles.
Ahora... en función del menester concreto al que me dedique en el futuro... puedo necesitar de nuevas formaciones más especializadas.

---

# Objetos de Kubernetes / Configuraciones en kubernetes

## POD

Es la unidad mínima de trabajo en kubernetes, con respecto a "carga de trabajo" (WORKLOAD)
Un pod es un conjunto de contenedores. En kubernetes, los contenedores no se crean de forma independiente. Van siempre en grupo... puede ser un grupo de 1.
Los contenedores de un pod:
- Tengo garantizado que se despliegan en el mismo host 
- Comparten configuración de red:
  - Tienen la misma IP (heredada del pod)
  - Son capaces de hablar entre si mediante la palabra "localhost"
- Pueden compartir volúmenes de almacenamiento locales (a nivel del host)
- Escalan juntos... lo que kubernetes hará en un momento dado si se lo pido es crear replicas de un pod.... y al hacerlo, replica cada contenedor del pod.

> Por ejemplo...
> Quiero montar un wordpress... que es una aplicación web, desarrollada en php, que corre dentro de un servidor web con soporte php... y que necesita una BBDD para operar.
Cuántos contenedores quiero?
Podría tener 1 contenedor con todo? PHP(los ficheros de WP) + Apache HTTPD + MariaDB junto? SI
    Lo haría alguna vez? NUNCA... por qué?
        - Si algo falla, quiero tener fácil identificar lo que falla... y ser capaz de reiniciar ese componente de forma independiente.
        - Si quiero actualizar el software de un componente (BBDD), puedo hacerlo de forma independiente.
        - El objetivo de un contenedor es crear un entorno aislado donde correr un proceso (o varios... muy relacionados)...
          - No tiene sentido juntar 2 procesos muy diferentes entre si.
        - Quiero que escalen juntos? Por cada copia del servidor web (2 instancias) quiero una instancia de la BBDD? NO
              BBDD MariaDB <<<< Copia 1 de mi WP <<<<     (balanceador de carga)  <<<<<<  Usuarios finales
                           <<<< Copia 2 de mi WP <<<<
Podría por ejemplo montar 2 contenedores:
- Apache HTTPD + PHP + WP
- MariaDB
Podría por ejemplo montar 3 contenedores:
- Apache HTTPD
- PHP + WP
- MariaDB
Podría por ejemplo montar 4 contenedores:
- Apache HTTPD
- PHP + WP
- MariaDB
- REDIS (Cache)
Vamos a por la más básica: 2 contenedores:
- Apache HTTPD + PHP + WP
- MariaDB

> Pregunta: Los pongo en el mismo pod o en 2 pods distintos? Siempre en distintos pods

    x Necesito que desplieguen en el mismo host
        x Tienen que compartir volúmenes de almacenamiento locales (a nivel del host)
    x Necesito/Me facilita la configuración que compartan configuración de red (misma IP)
    x Quiero que escalen juntos

> Voy a complicar la instalación... 
Quiero ser capaz de capturar los logs (access.log y el error.log del apache) y centralizarlos en ElasticSearch... para su consulta posterior desde Kibana.
Necesito un agente de monitorización que vaya leyendo esos ficheros de log y los mande al ElasticSearch: FluentD, FileBeat
Es decir: 
    - Servidor Web (apache)
    - Filebeat (o fluentd) leyendo los logs del apache

1 contenedor o 2 contenedores? Son 2 programas independientes.. con sus versiones independientes... con sus procesos independientes...
Uno está escribiendo un fichero...
El otro estará leyendo ese fichero... Pero son procesos independientes: 2 contenedores

Esos 2 contenedores (Apache, FileBeat), en el mismo pod o en 2 pods?

    proceso corriendo HTTPD
                        |
                        v
                        Archivo access.log (Dónde quiero tener almacenado físicamente este fichero)
                        ^
                        |
    proceso 2 corriendo FileBeat    -----> (Kafka <--- Logstash ---> Logstash --->) ES

    Me interesan 2 contenedores, ya que quiero poder reiniciar/actualizar cada uno de esos programas de forma independiente...

    Me interesa en este caso tenerlos en 1 pod. Por qué?
    Necesito que tango el proceso HTTPD como el proceso FILEBEAT tengan acceso al fichero.
    Es decir, necesito un volumen de almacenamiento al que los 2 procesos tengan acceso.
    - Podría montar un volumen en local en la máquina, si ambos procesos corren en la misma máquina.
    - Podría montar un volumen en red (NFS), y que los procesos, estando en máquinas físicas diferentes tengan acceso a ese volumen.
    Cuál me interesa más? En este caso, la Opción 1. Estamos hablando de ficheros de log.... y no quiero petar la RED con logs viajando por ahí de continuo. Además, esa operación de escritura en una carpeta compartida en red sería muuuucho más lenta que escribir en el HDD local de la máquina. Es un log... no quiero que frene el desempeño de mi app.
    Siempre optaré por un volumen local. Ahora bien... si lo tengo en un volumen local (a nivel del host) y necesito que ambos procesos tengan acceso al volumen (y por ende al fichero), necesito que los 2 procesos estén corriendo en el mismo host, para que puedan tener acceso a un volumen local.

        √ Necesito que desplieguen en el mismo host
            √ Tienen que compartir volúmenes de almacenamiento locales (a nivel del host)
        x Necesito/Me facilita la configuración que compartan configuración de red (misma IP)
        √ Quiero que escalen juntos:
            Para cada apache, quiero su propio filebeat
            Y si monto un nuevo apache en un nuevo servidor, quiero ahí un nuevo filebeat para procesar sus logs (desaguarlos, sacarlos de ese servidor y mandarlos a un ES)
        
        Quiero1 pod en este caso, con 2 contenedores.
    
    En un caso como este, una configuración habitual es:
        Monto un volumen en RAM (tomo 100 Kbs de la RAM y los uso como una carpeta de un HDD)
        Configuro el log de apache para tener 2 archivos de máximo 50Kbs rotados... y que se guarden en esa carpeta de la RAM.
        El apache va a ser capaz de escribir ahí como un tiro (RAM)
        El filebeat va a ser capaz de leer de ahí los datos como un tiro (Es en ram)
        La RAM no es persistente... pero para eso tengo el ES... que es persistente.
        Puede pasar que se me caiga un servidor... y justo los datos que no haya procesado aún el Filebeat los pierda.
            Esto es muy poco habitual.. y en caso que ocurra, pierdo 3 datos... que estamos hablando de accesos a una web... no de transacciones bancarias.... no es relevante... intentaré que no ocurra, pero si ocurre (un determinado día... tampoco es algo que rueden cabezas)
            Prefiero que las apps vayan muchísimo más rápido, no petar el HDD, ni la red y arriesgarme a un día cada año perder 3 datos de acceso a la web.
        El contenedor de filebeat es lo que llamamos un contenedor SIDECAR

> Cuántos pods voy a crear en un cluster de kubernetes? 

NINGUNO... yo no creo pods... y puedo hacerlo... pero no quiero comerme ese marrón. Kubernetes quiero que haga ese trabajo.

Hay apps (básicamente las que guardan datos y trabajan en cluster, eligiendo un maestro: BBDD-MariaDB, Sistema de mensajería-KAFKA, indexador-ES), que requieren un número impar de procesos para evitar el fenómeno llamado BRAIN SPLIT. Esas apps aunque tengan muchos procesos en cluster, sólo 1 opera como maestro, que es elegido por votación... Para asegurar una mayoría absoluta(mitad de nodos+1) en la votación se toma un número impar.

    MariaDB1*
     |
    MariaDB2
     |
    MariaDB3
     
    MariaDB4
     |
    MariaDB5

Y para ello, lo que vamos a configurar en kubernetes son PLANTILLAS DE PODS... que son las que kubernetes usará para crear los pods.
Yo le diré a kubernetes: 
Ahí tienes una plantilla de pod... como esa 5 pods. Y ya kubernetes se encargará de crear esos 5 pods.

Esto lo hacemos mediante los objectos:
- DEPLOYMENT        Es una definición de plantilla de pod + Número de réplicas deseado
                        Todas las replicas (pods) de la plantilla del pod comparten volúmenes de almacenamiento
                        Apache1, Apache2, ApacheN que todos accedan a la misma carpeta de almacenamiento de datos persistentes
                        - Scrips, aplicaciones web
- STATEFULSET       Es una definición de plantilla de pod + Número de réplicas deseado + definición de una petición de volumen persistente
                        Cada réplica tiene asociada su propia petición de volumen persistente... y por ende su propio volumen persistente  
                        MariaDB1, MariaDB2, MariaDBN que cada uno tenga su propia carpeta de almacenamiento de datos persistentes
                        Todos los productos de software que operan en cluster almacenando datos, los configuramos mediante STATEFULSET:
                            - Indexador: ES, SOLR
                            - BBDD: MariaDB, PostgreSQL, SQLServer, Oracle
                            - Sistema de mensajería: KAFKA, RABBITMQ
- DAEMONSET         Es una definición de plantilla de pod... de la que kubernetes hará 1 replica para cada máquina (nodo) que tenga en el cluster
                    Es raro que nosotros trabajemos con DaemonSets... Están reservados para tipos de software muy peculiares: 
                        - Monitorización que lea métricas de cada servidor físico.
                        - Quiero una red virtual entre las máquinas... y en cada una necesito un programa que gestione las comunicaciones en esa red virtual.

> Ejemplo del WP con MariaDB

    2 tipos de pods: 1 para el apache+php+wp y otro para la BBDD
    Imaginad que en un momento dado quiero tener:
      - 8 instancias (pods del tipo del servidor WEB)
      - 3 instancias (pods del tipo de la BBDD)

    Los apaches (con php y wp) guardan datos? SI... los ficheros que subo a la web... una imagen, un pdf... se guardan en una carpeta
        - Quiero que cada apache tenga su propia carpeta donde guardar los ficheros que se le suban?
        - O quiero una carpeta única a la que tengan acceso todos los apaches? ESTA. los archivos subidos a ubn apache, deben ser accesibles desde el resto

    La BBDD guarda datos? SI... los datos de los usuarios, los posts, los comentarios, las categorías, las etiquetas, metadatos de los ficheros
        - Quiero que cada BBDD tenga su propia carpeta donde guardar los datos? ESTA
        - O quiero una carpeta única a la que tengan acceso todas las BBDD?

        mariadb1    dato1 dato2
        mariadb2    dato1 dato3
        mariadb3    dato2 dato3

        Con 3 máquinas mejoro el rendimiento en un 50%... en una máquina en una unidad de tiempo guardo 1 dato -> 2 ud de tiempo guardo 2 datos
                                                          Con 3 máquinas en 2 unidades de tiempo guardo 3 datos
                                                          Mejoro en un 50% (3 frente a 2 máximo teórico) el rendimiento.
        mariadb1    dato1   dato2   dato4
            |
        mariadb2    dato1   dato3   dato4
            |
        mariadb3    dato1   dato3   dato5       Me da igual a quién le pida el dato.. que internamente hablarán entre si para entregármelo... 
            |                                      Pero yo me olvido... ya se encarga el sistema en automático de ese trabajo.
        mariadb4    dato2   dato3   dato5
            |
        mariadb5    dato2   dato4   dato5

        En 3 unidades de tiempo guardo 5 datos... 3, si tuviera 1 máquina...  Mejoro el rendimiento en 3/5 = 60% (5 frente a 3)

        Si me voy a 7 máquinas: cada dato lo puedo guardar en 2, 3, 4, 5 o 6 máquinas... en función de eso, el rendimiento es uno u otro.:
            - 2 nunca
            - 5 o 6 tampoco Mejoro poco el rendimiento
            - Habitualmente del dato quiero 3 copias en Producción

        Cuando llegue un dato1? qué MariaDB guarda el dato? Todas, algunas, solo 1?
            TODAS       Nunca en todas... si es así, no tengo Escalabilidad
            ALGUNAS     ESTA: Me ofrece HA / ESCALABILIDAD
            UNA         Nunca en 1... no tengo HA, si esa máquina se cae, el dato deja de estar disponible
        (NOTA: Podéis cambiar Mariadb, por vuestro almacenador favorito: ES, Kafka, REDIS, PostgreSQL)

        4 máquinas... y si se caen 3 la app sigue en funcionamiento
            Las máquinas nunca superan en configuración normal un 25% de carga de trabajo (CPU, RAM)

        Otra cosa a tener en cuenta es que esas cifras son las máximas teóricas alcanzables... En realidad es mucho menos... por las comunicaciones internas.

        Esto implica que cada replica/instancia de la bbdd tiene que tener su propia carpeta donde guardar los datos.


# Gestión de datos a nivel de sesión en un servidor web/de aplicaciones

    Serv.apps 1 (Weblogic)          BALANCEADOR DE CARGA            usuario1 (servidor 1)
        appA                            sticky sessions
    Serv.apps 2 (Weblogic)
        appA
    
    Para evitar que aun teniendo sticky sessions configuradas en el balanceador, mis datos de session se pierdan si una máquina se cae y se me manda a otra lo que hacemos es montar una cache de sesiones distribuida en RAM entre las máquinas, de forma que el dato se guarde en varias máquinas... y si una se cae, que esté disponible en otras:
    - REDIS
    - MEMCACHED
    - Weblogic: Coherence
    - JBos: Infinispan

## Contenedores en pods

> HECHO 1: 
Dentro de un pod, podemos definir / albergar varios contenedores.

> HECHO 2:
Qué tipos de software pueden ejecutarse en un contenedor?
- Aplicaciones
- Servicios / Demonios
- Scripts
- Comandos

Hay una diferencia grande entre las aplicaciones, servicios y demonios, con respecto a los scripts/comandos:
- Las aplicaciones, servicios y demonios, son software que se ejecuta de forma continua...indefinidadamente... hasta que se les para explicitamente
- Los scripts/comandos, son software que se ejecuta de forma puntual... y que no quedan corriendo en el tiempo indefinidadamente.... al acabar su trabajo se paran... ellos solitos.

Kubernetes monitoriza / vela por que los contenedores de un pod estén en funcionamiento:
Cómo sabe kubernetes que un contenedor está funcionando bien?
A priori, igual que cualquier gestor de contenedores (containerd, crio, docker...) monitorizando el proceso 1 del contenedor (su proceso principal) para ver si está corriendo.

Lo que pasa es que Kubernetes si ve que un contenedor de un POD se cae (su proceso 1 se detiene) se vuelve LOCO, entra en PANICO !
Y hace TODO LO QUE PUEDA por iniciar de nuevo el pod y por ende los contenedores que hay dentro. -> IMPACTO ENORME:

Puedo ejecutar un script o un comando dentro de un contenedor de un pod? SI... pero NO
Kubernetes, dentro de un POD me permite definir 2 tipos de contenedores:
- containers
  Si un container se detiene, kubernetes entra en pánico...y reinicia el pod entero... y si lo tiene que reiniciar miles de veces, lo reinicia.
  Y que no podemos cambiar! 
  Eso invalida el usar este tipo de contenedores para ejecutar scripts/comandos.
  Imaginad un script de backup de una BBDD.
- init-containers
  Los init containers están pensados para ejecutar software que ACABE (scripts/comandos)... si no acaban Kubernetes se vuelve loco... entra en PANICO... y reinicia el pod.

    Los contenedores (containers) de un poc se ejecutan en paralelo
    Los init-containers se ejecutan secuencialmente, según el orden de definición en la configuración del pod.
    Y es después de que todos los init-containers hayan acabado, cuando se ejecutan los containers.

Habitualmente usamos init-containers para tareas requeridas antes de que el contenedor principal se inicie:
    - Descargar algunos ficheros
    - Descomprimir algunos ficheros
    - Crear una estructura de carpetas
    - ...

No usamos este tipo de contenedores para tareas puntuales que yo quiera ejecutar en el cluster:
- Backup de una BBDD
- Lanzar un script que me haga un análisis de seguridad
- ...

Si lo que quiero es ejecutar comandos/procesos independientes de forma puntual en el cluster, lo que hago es crear un JOB de kubernetes.

Un JOB es un conjunto de contenedores que ejecutan scripts/comandos.

## RESUMIENDO

Si quiero ejecutar un servicio, dentro del cluster necesitaré un POD
Si quiero ejecutar un script o un comando, dentro del cluster necesitaré un JOB

Son 2 conceptos similares... pero con una diferencia clave:
- Los PODs se crean para ejecutar trabajos (procesos) que se quedan de forma continua en el tiempo (no acaban): SERVICIOS, APPS
- Los JOBs se crean para ejecutar trabajos (procesos) que acaban (no se quedan de forma continua en el tiempo): SCRIPTS, COMANDOS
En ocasiones, dentro de un POD, creo initContainers... para ejecutar acciones que no duran en el tiempo (SCRIPTS/COMANDOS) antes del inicio de los contenedores del POD (que si se quedan de forma continua en el tiempo).
Pero si solo quiero un script/comandos... sin nada detrás (una app, un servicio) lo que configuro/necesito es un JOB

> Cuantos jobs voy a crear en un cluster de Kubernetes? De pocos a ninguno... yo no creo jobs... y puedo hacerlo... pero no quiero comerme ese marrón habitualmente. Kubernetes quiero que haga ese trabajo.

Si hay que hacer una copia de la BBDD (backup) todas las noches, cada noche querré que kubernetes cree un JOB.
Y para ello le daré una plantilla de JOBs:
- CRONJOB: Que contiene la definición de una plantilla de JOB + un CRON (horario) de creación de JOBs desde esa plantilla.

CRONJOB a es un JOB lo que los DEPLOYMENTs/STATEFULSET/DAEMONSET son a los PODs

# NAMESPACE

Es una agrupación lógica de recursos/configuraciones/objetos dentro de un cluster de kubernetes.
Pero no es para que me sea fácil buscarlos... sino para poder ADMINISTRAR características clave de esos recursos/configuraciones/objetos.

Los namespaces me permiten crear una segmentación horizontal del cluster de kubernetes.... es decir, poder montar dentro del cluster diferentes 
entornos semiAISLADOS entre SI... que comparten el mismo cluster de kubernetes.

Podría tener un namespace para MIWEB-producción... dentro de ese namespace tendría POD: Apache + POD: MariaDB
                                                                                        Un balanceador de carga:        SERVICE
                                                                                        Política de autoescalado:       HORIZONTALPODAUTOSCALER
                                                                                        Reglas de firewall de red:      NETWORKPOLICY
                                                                                        Configuración de proxy reverso  INGRESS

Podría tener un namespace para MIWEB-desarrollo... dentro de ese namespace tendría POD: Apache + POD: MariaDB
                                                                                        Configuración de proxy reverso

Podría tener un namespace para MIWEB2-producción... dentro de ese namespace tendría POD: Apache + POD: MariaDB
                                                                                        Un balanceador de carga
                                                                                        Política de autoescalado
                                                                                        Reglas de firewall de red
                                                                                        Configuración de proxy reverso

Normalmente creamos NS asociados a:
- Aplicaciones diferentes
- Entornos diferentes (desarrollo, producción)
- Clientes diferentes

Los administradores de un cluster de Kubernetes pueden IMPONER LIMITES DE USO DE LOS RECURSOS DE UN CLUSTER DE KUBERNETES a un namespace:
- Los pods del ns MIWEB-desarrollo solo pueden hacer uso de un total de 3 cores del cluster
- Los pods del ns MIWEB-producción solo pueden hacer uso de un total de 10 cores del cluster

Los LIMITRANGES y los RESOURCEQUOTAS son objetos de kubernetes que se usan para definir esos límites de uso de recursos de un cluster de kubernetes a un namespace.

A cada "usuario" le permitiré acceder a unos determinados namespaces... y no a otros.
O le daré distintos privilegios de acceso a distintos namespaces.
    WEB-DESARROLLO: Puede crear pods
    WEB-PRODUCCION: No puede crear pods... aunque puede verlos y monitorizarlos

# Arquitectura de un cluster de kubernetes

Cluster de máquinas: NODES

    Nodo de plano de control 1 \
    Nodo de plano de control 2  > En estas máquinas es donde se despliega el software de kubernetes
    Nodo de plano de control 3 /
        - KUBELET
            v 
        - Un gestor de contenedores (Crio o ContainerD)

    Nodo de trabajo 1:
        - KUBELET
            v 
        - Un gestor de contenedores (Crio o ContainerD)

    Nodo de trabajo 2:
        - KUBELET
            v 
        - Un gestor de contenedores (Crio o ContainerD)

    ...

    Nodo de trabajo N:
        - KUBELET
             v 
        - Un gestor de contenedores (Crio o ContainerD)

Kubernetes no es un único programa, es una colección de programas:
- Un software que se monta a hierro en cada máquina del cluster de kubernetes: KUBELET
  Es un servicio que queda corriendo en cada host.
  Este programa es el que se encarga de hablar (dar instrucciones) al gestor de contenedores configurado en esa máquina.
- Un software que nos permite crear clusters y administrarlos (añadirle nodos... o quitarselos)
  Eso es un comando que se monta a hierro en cada máquina del cluster de kubernetes: KUBEADM
- Otra serie de aqplicaciones, que se ejecutan como pods (en contenedores) dentro del propio cluster de kubernetes:
  - API SERVER:             Ofrece servicios REST para que otros programas puedan hablar con el cluster de kubernetes
  - CONTROLLER MANAGER:     Es el que se encarga de que el cluster de kubernetes esté en el estado deseado (el que hace el trabajo)
  - SCHEDULER:              Determina en qué nodo se despliega cada pods
  - ETCD:                   Base de datos de configuración del cluster de kubernetes
  - COREDNS:                Servicio de DNS del cluster de kubernetes
  - KUBEPROXY:              Servicio de proxy de red del cluster de kubernetes

Eso viene de forma estandar en cualquier cluster de kubernetes que montemos. Pero... encima de esas debemos montar obligatoriamente otras a nuetra elección, y podemos montar otras adicionales:
- Una red virtual entre los nodos del cluster de kubernetes: Montaremos un driver que cree y controle esa red virtual
  OBLIGATORIO 
- Un proxy reverso para el acceso a las aplicaciones desplegadas en el cluster de kubernetes: IngressController
- Un provisionador de volúmenes de almacenamiento: Montareamos un programa que permita entregar volumenes dinámicos a los pods que los necesiten

Adicionalmente podemos montar:
- Dashboard: Una aplicación web que nos permite monitorizar y administrar el cluster de kubernetes
- MetricServer: Un servicio que recoge métricas de los pods y las almacena en una base de datos
- Prometheus/grafana: Un sistema de monitorización de los pods del cluster de kubernetes
- Provisionador de certificados: Un programa que se encarga de renovar los certificados de seguridad del cluster de kubernetes
- Gestor de mallas de servicio: ISTIO/LINKERD
- ....

Importante es entender que:
KUBERNETES es una ESPECIFICACION... no un software.
Según esa especificación, cualquier cluster que quiera llamarse cluster de kubernetes, debe tener montado un conjunto de programas... que son los que hemos visto.... y debe permitirme la creación de todos esos objetos que hemos visto.

Pero hay muchas implementaciones de kubernetes... 
- K8S: Cluster de kubernetes montado por Google (OpenSource) Más habitual en entornos de producción
- K3S: Cluster de kubernetes con las cosas mínimas para que funcione... y que ocupa muy poco: IoT
- MINIKUBE: Cluster de kubernetes que se monta en una sola máquina... para hacer pruebas/desarrollo
- KIND: Cluster de kubernetes que se monta en una sola máquina... para hacer pruebas/desarrollo... basado en Contenedores DOCKER
        Kubernetes in Docker... Montamos un cluster entero de kubernetes dentro de un contenedor de docker
- OpenShift: Es la distribución de Kubernetes de REDHAT... basada en K8S... pero con muchas cosas adicionales:
  - Su propio sistema de monitorización
  - Su propio dashboard
  - Escalabilidad automática de máquinas -> CLOUDS
- Minishift: Es la distribución de Kubernetes de REDHAT... para hacer pruebas/desarrollo
- Tamzu: Es la distribución de Kubernetes de VMWARE... 

### REDHAT

De todo producto ofrecen una versión gratuita / sin soporte:
                                <<<<<   UPSTREAM (gratis)
RHEL                                    Fedora
JBOSS                                   Wildfly
Openshift Container Platform            OKD

Una cosa es un cluster de Kubernetes.... y otra cosa es cómo interlocuto (hablo) con un cluster de kubernetes.
Kubernetes define una herramienta (de hecho 2) para atacar a clusters de kubernetes:
- KUBECTL: Es una herramienta de línea de comandos que me permite hablar con un cluster de kubernetes
           Es el equivalente al comando docker... que es un cliente... que me permite hablar con el gestor de contenedores docker, que es un demonio llamado dockerd que queda en la máquina corriendo. 
           Este comando ataca al API SERVER del cluster de kubernetes
- DASHBOARD: Es una aplicación web OFICIAL que me permite hablar con un cluster de kubernetes
            No viene de serie instalada en un cluster de kubernetes... pero es una aplicación oficial de kubernetes que me permite hablar con un cluster de kubernetes.
            Mucho cuidado con esta.
- HELM: Es una herramienta de línea de comandos que me permite desplegar aplicaciones en un cluster de kubernetes
- KUSTOMIZE: Es una herramienta de línea de comandos que me permite generar despliegues de apps en un cluster de kubernetes

----

Plan para mañana:

- Crear una VM en AWS (Ubuntu)
- Desisntalar docker
- CRIO
- Desactivar la SWAP de la máquina (No lo quiere kubernetes... es un requisito)
- Instalar kubeadm, kubelet, kubectl en esa máquina. (APT)
  - Realmente, de cara a instalar un cluster, el kubectl lo montaríamos en otra máquina fuera del cluster... aqquí lo vamos a montar en la misma máquina porque no tenemos otra.
  - De hecho en un entorno de producción puedo tener el kubectl en 57 máquinas instalado... fuera del cluster
- Usaremos kubeadm para crear un nuevo cluster de kubernetes en esa máquina (un cluster de 1 nodo)
  En este momento es cuando se descargan las imágenes de contenedor y se crean los pods del plano de control de kubernetes:
    - API SERVER
    - CONTROLLER MANAGER
    - SCHEDULER
    - ETCD
    - COREDNS
    - KUBEPROXY 
- En se cluster montaremos una red virtual entre los nodos del cluster de kubernetes (solo tenemos 1 nodo... pero es obligatorio aún así)
  - Hay decenas de plugins de red virtual disponibles en kubernetes:
    - Flannel... se usa mucho en entornos de pruebas/desarrollo: Sencillo, rápido de montar... pero CON MENOS FUNCIONALIDADES
    - Calico... se usa mucho en entornos de producción: Completo, costoso de montar... pero CON MÁS FUNCIONALIDADES
      Nosotros vamos a montar el bueno: CALICO 
- En el momento que tengamos cluster empezaremos a cargarle algunas apps:
  - Dashboard
  - MetricServer
--- Llegados a este punto, lo tendremos todo listo para comenzar a trabajar con kubernetes.... y ver más cosas de kubernetes.
- Prepararemos nuestros propios despliegues con todos los objetos de kubernetes que hemos visto.

    MARTES: Instalación del cluster
            Comenzaremos con PODS y Deployments
    MIERCOLES:
            PVCs, PVs
            ConfigMaps, Secrets
            StatefulSets
    JUEVES: 
            Services
            Ingress
            NetworkPolicy
    VIERNES:
            Jobs, CronJobs
            ResourceQuotas, LimitRanges
            HorizontalPodAutoscaler
            Afinidades y tolerancias
            HELM
        + Uniremos todos los clusters que vamos a crear mañana (clusters de 1 máquina) en un único cluster de kubernetes:
          Cada máquina que vamos a crear mañana tendrá 16Gbs de RAM y 4 cores: Somos 9:
            - 1 cluster grande con : 9 nodos: 144Gbs de RAM y 36 cores 
