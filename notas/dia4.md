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
- 

kind
kubernetes in docker

did
docker in docker