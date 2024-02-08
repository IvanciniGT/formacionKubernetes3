# Comunicaciones en Kubernetes
    
    192.168.0.10:80 -> 
        192.168.0.100:30880
        192.168.0.101:30880
        192.168.0.102:30880                             192.168.0.10            Navegador: "http://web1.miempresa.com"
        192.168.0.103:30880                               ||                     |
Balanceador de carga EXTERNO                        web1.miempresa.com        MenchuPC
        |                                             |                          |
    192.168.0.10                                    DNS Externo            192.168.0.200
        |                                             |                          +
+------------- RED DE MI EMPRESA [192.168.0.0/16] ----------------------------------------------------------
|
||= 192.168.0.100 =Nodo1 (CP)
||                   Linux - NETFILTER
||                              10.10.1.101:3307 -> 10.10.0.103:3306
||                              10.10.1.102:8080 -> 10.10.0.102:80 | 10.10.0.112:80 (round robin)
||                              10.10.1.105:8081 -> 10.10.0.105:80
||                              192.168.0.100:30880 -> 10.10.1.105:8081
||                   Pod Kube-Proxy ^
||                   Kubelet -> CRIO
||                   Pod Controller manager (monitoriza los pods, contenedores, procesos... y los gestiona)
||                   Por Scheduler (ubica nuevos pods en el cluster)
||                   -10.10.0.10- Pod CoreDNS
||                                  mariadb-service => 10.10.1.101
||                                  wp-service      => 10.10.1.102
||                                  nginx           => 10.10.1.105
||= 192.168.0.101 =NodoA (TRABAJADOR)
||                   Linux - NETFILTER
||                              10.10.1.101:3307 -> 10.10.0.103:3306
||                              10.10.1.102:8080 -> 10.10.0.102:80 | 10.10.0.112:80 (round robin)
||                              10.10.1.105:8081 -> 10.10.0.105:80
||                              192.168.0.101:30880 -> 10.10.1.105:8081
||                   Pod Kube-Proxy ^
||                   Kubelet -> CRIO
||                   -10.10.0.102- Pod 1 - WP      
||                                       + Contenedor WP 10.10.0.102:80
||                                            /../wp-config.php -> db_host=10.10.0.101:3306 ...OPCION 1: RUINA !
||                                            /../wp-config.php -> db_host=mariadb-service:3307
||= 192.168.0.102 =NodoB (TRABAJADOR)   
||                   Linux - NETFILTER
||                              10.10.1.101:3307 -> 10.10.0.103:3306
||                              10.10.1.102:8080 -> 10.10.0.102:80 | 10.10.0.112:80 (round robin)
||                              10.10.1.105:8081 -> 10.10.0.105:80
||                              192.168.0.102:30880 -> 10.10.1.105:8081
||                   Pod Kube-Proxy ^
||                   Kubelet -> CRIO
||                   -10.10.0.105- Pod 1 - NGINX - Como proxy reverso = INGRESS CONTROLLER      
||                                       + Contenedor nginx 10.10.0.105:80
||                                              REGLA: http://web1.miempresa.com => wp-service:8080 < INGRESS
||                   -10.10.0.112- Pod 2 - WP      
||                                       + Contenedor WP 10.10.0.112:80
||                                            /../wp-config.php -> db_host=mariadb-service:3307
||
||= 192.168.0.103 =NodoC (TRABAJADOR)
||                   Linux - NETFILTER
||                              10.10.1.101:3307 -> 10.10.0.103:3306
||                              10.10.1.102:8080 -> 10.10.0.102:80 | 10.10.0.112:80 (round robin)
||                              10.10.1.105:8081 -> 10.10.0.105:80
||                              192.168.0.103:30880 -> 10.10.1.105:8081
||                   Pod Kube-Proxy ^
||                   Kubelet -> CRIO
||                   -10.10.0.103- Pod 1 - MariaDB      
||                                       + Contenedor MariaDB 10.10.0.103:3306
 |
 Red virtual de kubernetes [10.10.0.0/16]


## Servicio - Service

### Servicio de tipo clusterIP

Es una IP de balanceo (que no de un balanceador) + Entrada en el DNS de kubernetes.

- Creo un Servicio para MariaDB:  mariadb-service , IP = 10.10.1.101:3307
                                  ^^^^^^^^^^^^^^^                    ^^^^
                                                     los defino yo
    Esa IP de balanceo, por detrás no tiene ningún programa específico (un balanceador, nginx, haproxy, apache...) 
    Esa IP es SOLO una entrada en NETFILTER.

    Con el servicio hemos conseguido:
    - HA: Si un pod de MariaDB se cae, Kubernetes lo levanta en otro sitio, cambia la regla en netfilter
            para que apunte a ese otro sitio y todo sigue funcionando.

- Creo un Servicio para WP:       wp-service , IP = 10.10.1.102:8080 
                                  ^^^^^^^^^^                    ^^^^

### Servicio de tipo NodePort

Es un servicio de tipo ClusterIP + se abre en cada nodo del cluster un puerto por encima del 30000 que redirige al servicio interno
Es decir:
    - Es una IP de balanceo (que no de un balanceador) 
        + Entrada en el DNS de kubernetes
        + Puerto en cada nodo (> 30000) que redirecciona al servicio interno

- Creo un Servicio para WP:       nginx , IP = 10.10.1.105:8081 + puerto a exponer en cada nodo: 30880
                                  ^^^^^                    ^^^^

### Servicio de tipo LoadBalancer

Es un servicio de tipo NodePort + Configuración automatizada de un balanceador externo compatible con kubernetes.

Si mi cluster de Kubernetes lo he contratado a un cloud: AWS, Oracle, IBM, AZURE, GPC, los clouds me "dan" (previo paso por caja €€€)
un balanceador externo preconfigurado compatible con kubernetes... ME OLVIDO

Si mi cluster lo tengo on premises, tengo que montar YO un nalanceador externo compatible con kubernetes: HAY 1: METALLB


### DNS Externo

Por defecto no viene nada en kubernetes para autoconfigurar DNSs externos.
En OPENSHIFT (la distro de kubernetes de la gente de REDHAT) si hay un nuevo tipo de objeto que no existe en los kubernetes normales:

- ROUTE

En kubernetes hay un proyecto oficial, independiente, que debo montar y configurar: ExternalDNS
Que me permite que Kubernetes configure en automático entradas DNS en un montón de Servicios de DNS comerciales.

### NetFilter

Es un componente (programa) del kernel de linux. Cualquier paquete de red que pasa por una máquina linux, es filtrado por netfilter.
Os suena IPTABLES... Es solo una forma de dar reglas a NETFILTER.

> Pregunta:

En un cluster promedio, cuantos servicios voy a tener creados de cada tipo:

                        Valor absoluto      
                    -----------------------------
    ClusterIP                 resto                    Comunicaciones internas
    NodePort                  0                        Comunicaciones externas
        Quiero yo estar configurando balanceadores externos a mano? NO
    LoadBalancer              1...2                    Comunicaciones externas
    
Nodeport se usa en cursos... cuando tengo un cluster de 1 máquina...

Nos falta 1 cosita... que tenemos en TODO ENTORNO DE PRODUCCION QUE SE PRECIE.....Un proxy reverso.

# Proxies y proxies reversos (o inversos)

    Le tengo a la salida de la empresa de menchu
                    v
    Menchu  --->  Proxy  ----------------------------->  Proxy reverso  --->  Servidor WEB (wp)
    Felipe  ------------------------------------------>        ^
                                                Le tengo a la entrada de mi empresa
    
El proxy está para proteger a Menchu... PROXY = BUENO !
El proxy hace el trabajo en lugar de Menchu... Si alguien se lleva una ostia, que sea el proxy, no menchu.
Que el servidor no conozca a Menchu... solo al proxy

- NGINX: Es un proxy reverso... que con el tiempo gana funcionalidades de servidor web
- Apache HTTPD: Nació como servidor web... y con el tiempo ganó funcionalidades de proxy reverso
- Traeffic
- Envoy
- HAProxy

Voy a montar un proxy reverso dentro de kubernetes... y es el único servicio que expongo. 
Ese proxy reverso es el que INTERNAMENTE se comunica con TODOS los servicios del cluster que quiera exponer al público

Quizás voy a montar 2 proxies reversos... Uno interno a mi empresa... y otro expuesto a internet... con otras reglas de configuración.
Quizás un tercero... para administradores del cluster... YA.

Alguien sabe cómo se llama a ese proxy reverso en el mundo KUBERNETES? INGRESS CONTROLLER

En mi cluster montaré un determinado INGRESS CONTROLLER de mi interés.
Pero a ese INGRESS CONTROLLER (Proxy reverso) le iré dando REGLAS: 
Las reglas de configuración de un PROXY REVERSO (INGRESS CONTROLLER) en kubernetes se llaman: INGRESS
    
    Regla: 
        Si alguien te llama (a ti ingress controller) usando la url: http://miapp-miempresa.com -> http://miwp:8080

- Ingress Controller: NO ES UN OBJETO DE KUBERNETES... es un programa que despliego en kubernetes
- Ingress: ES UN OBJETO DE KUBERNETES. Son reglas que aplican al INGRESS CONTROLLER CONCRETO que haya instalado.

---
# Pruebas

Vamos a montar unas apps en el cluster.... y el objetivo es dejar a kubernetes al mando del cluster. 
Yo me quiero desentender.

Como sabemos, si kubernetes detecta que un pod se cae, lo levanta de nuevo, 
en la misma máquina o en otra... (según lo que diga el scheduler).

Pero... la pregunta es: ¿Cómo sabe kubernetes que un pod se ha caído?

Lo primero: Kubernetes, a través del gestor de contenedores que use (CRIO, containerd) 
mira el proceso principal que está corriendo en el contenedor.

Si ese proceso se cae, kubernetes reinicia el pod. ESTO LO HACE EN AUTO.

Eso es suficiente? NO

Un proceso puede estar levantado ... pero funcionando de forma inadecuada.

Imaginad un servidor de aplicaciones JAVA: tomcat, weblogic, websphere.
Eso es un proceso JAVA que se levanta (JVM) ... en esos servidores configuro un pool de ejecutores (HILOS atendiendo peticiones http)
A veces los hilos se me quedan pillaos... en un momento me puedo quedar con todos los hilos pillaos...
o el 90% y casi no estoy respondiendo peticiones... hago una cola de cojones.

Para ello, en kubernetes existente los probes... y hay 3 tipos:

- Startup probes
    Para ver si el proceso de un contenedor ha arrancado adecuadamente
    Espera 10 segundos... que tarda la app en arrancar más o menos    
    Cada 5 segundos ejecuta qué? curl http://localhost:8080/status ---> OK: 200
    Si no te responde en 3 segundos KO
    Si falla 10 veces, dejando entre intentos 5 segundos: REINICIA EL POD
        Le estoy dando a la aplicación 10+ 5x10 = 60 segundos para arrancar. Si en 6y0 segundo no contesta, reinicia.
ESTA PRUEBA SE EJECUTA AL ARRANQUE
- Liveness probes
    Para ver si el proceso que corre en un contenedor está operativo
    Cada 5 segundos ejecuta qué? curl http://localhost:8080/status ---> OK: 200 json :{status: RUNNING | MAINTENANCE}
    Si no te responde en 3 segundos KO
    Si falla 3 veces, dejando entre intentos 5 segundos: REINICIA EL POD
ESTA PRUEBA SE EJECUTA DE PERPETUA
- Readiness probes
    Para ver si el proceso que corre en un contenedor está listo para prestar servicio
    Cada 5 segundos ejecuta qué? curl http://localhost:8080/status ---> OK: 200 json :{status: RUNNING}
    Si no te responde en 3 segundos KO
    Si falla 3 veces, dejando entre intentos 5 segundos: LO SACA DEL POOL DEL SERVICIO (lo saca de balanceo)
ESTA PRUEBA SE EJECUTA DE PERPETUA

Imaginad una aplciación web que tengo.... qué pruebas le podría definir?
Al wp le puedo pedir que se actualice! -> La web queda en modo MANTENIMIENTO.
    Está viva... no quiero que reinicie... no jodas, que me dejas la instalación a medias
    Pero... está listo el contenedor (web) para prestar servicio a los usuarios normales? NO... la saco de balanceo

Esos los puedo configurar a nivel de cada contenedor. 

Tengo una BBDD MARIADB.
Le doy 3 minutos para que arranque... hasta que sea capaz de conectar con ella con usuario admin.

Cómo se si está viva... (liveness) si me puedo conectar a ella como administrador de la bbdd.
Eso implca que está ready? NO... puede estar haciendo un backup... o un restore... en modo mnto.

Para que esté ready (y la meta en balanceo) debe ser capaz de permitirme conectarme pero con un usuario normal, no con admin

Las pruebas concretas que puedo configurar:
- Hacer peticiones a un puerto http...
- Ejecutar un comando dentro del contenedor y ver el código de salida: 0 (GUAY) o no (RUINA)

# Recursos

Todo contenedor en kubernetes tiene una limitación de acceso a los recursos del cluster... 
LA PONGA YO O NO ! Si no la pongo, en el ns hay definidos unos valores por defecto... que si no se han puesto, se heredan del cluster que tambien valores por defecto.
Esos valores por defeecto se configuran en un objeto que tiene kubernetes: LIMITRANGE

 resources:
    requests:       # Es lo que la aplicación solicita que se le garantice              NO INTERPRETAR COMO MINIMO
      cpu: 1
      memory: 2Gi
    limits:         # Es lo que la aplciación solicita que pueda llegar a usar          NO INTERPRETAR COMO MAXIMO
      cpu: 1500m    # Aquí no hay problema
      memory: 2Gi   # ESTE VALOR, a no ser que se conozca muy bien el funcionamiento de kubernetes, el de mis programas y que esté en un caso muy especial, SIEMPRE IGUAL AL REQUEST
                    # Aquí si hay problema

    Cluster         CAPACIDAD           COMPROMETIDO        SIN COMPROMETER     USO EN TIEMPO T
                    cpu    memoria      cpu     memoria     cpu     memoria     cpu     memoria
        nodo 1       4      10Gb                             0          2        0          2
            pod1wp                       3          5                            3          5   KUBERNETES REINICIA EL POD POR LISTO
            pod1mariadb                  1          3                            1          3
        nodo 2       4      10Gb                             4          5
            pod1nginx                    1          5        3          5        1          1   Y esto así siempre: CAGADA!
            
    Pods            REQUESTS            LIMITS
                    cpu    memoria      cpu     memoria
        pod1wp       3       5           10       8
        pod1mariadb  1       3           2        5
        pod1nginx    1       5           1        5
        
    El Scheduler es quién decide donde se ubica el pod... y para ello tiene en cuenta MUCHOS FACTORES:
        - Resources (El Scheduler solo tiene en cuenta los REQUEST del pod y lo COMPROMETIDO de los nodos... el USO se la pela!)
        - Afinidades
        - Tolerancias
        
    El request es lo que se garantiza a cada pod... con lo que en cualquier caso va a poder contar. Y es lo que usa el Scheduler

    CAGADA: Tengo mal dimensionado el pod... Hay 4Gbs que no se usan.... pero están bloqueados.
    
Este comportamiento no lo vemos solo en kubernetes.
En JAVA levantamos una JVM... y en a máquina virtual le configuramos la memoria RAM que puede tomar:
    -Xms1000m -Xmx1000m
        ^           ^
        ^           Memoria máxima
        Memoria inicial
        
    Y EN JAVA, la gente de JAVA me dice: LOS DOS IGUALES... a no ser...
    
Los request de kubernetes son una medida de GRACIA !
Si dentro de un contenedor tengo un programa JAVA: cuál es el primer sitio donde limito el uso de RAM? en JVM
Si dentro de un contenedor tengo una BBDD: cuál es el primer sitio donde limito el uso de RAM? en la BBDD

Si un programa tiene un bug o ha sido mal configurado, kubernetes lo capa!... como medida de gracia... antes de que afecte a otros programas.


En kubernetes, el objetivo es que una aplicación ruede en cluster... 
Yo no voy a configurar un megaservidor de apps JAVA con 64 Gbs de RAM y 16 cores...
    Voy a configurar 4 servidores con 16 Gbs y 4 cores... y voy escalando según hace falta...
    Si no estoy tirando recursos en muchas ocasiones
Y la clave está en elegir una buen ratio entre RAM y CPU = MONITORIZACION


# LimitRange

Además de establecer los valores por defecto de limit y request de resources de los containers, imponen límite máximo y mínimo a los contenedores en los request y limits.

# ResourceQuota

Limitan el total de consumo de RAM, CPU (y otros) acumulado dentro de un ns (por todos los pods que allí existan)