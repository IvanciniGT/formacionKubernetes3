# Creación de un cluster de Kubernetes

Kubernetes no se monta en una máquina... como docker, sino en tropecientas... acabamos con un cluster de máquinas.

Los contenedores que vayamos a crear deben tener comunicación entre si.
En docker es facil. Docker crea una red virtual interna en mi máquina.... similar a la red de loopback.
Kubernetes por contra necesita de una red virtual que opere sobre la red física que conecta los nodos,
de forma que los contenedores de un nodo sean capaces de ver a los de otro nodo.

Esa red virtual habrá que crearla. Para ello desplegaremos un driver de red en kubernetes... cuando tengamos cluster.
El problema es que ese trabajo requiere que tenga el cluster ya en marcha, para desplegar la red sobre él.
Pero ahora mismo no hay cluster.
No obstante queremos crear el cluster, lo que implica poner a funcionar todos los programas del plano de control de kubernetes: Api Server, CoreDNS, etcd, ControllerManager, Scheduler...
Y esos programas se instalan como contenedores del cluster... PERO NO HAY RED
La RED, para desplegarla necesita un cluster operativo.

Hacemos un truco... en el bootstraping del cluster, le decimos en que rango de red va a trabajar la FUTURA red virtual que crearemos.
Como por ahora los contenedores no se deben comunicar con otros contenedores de otra máquina (solo hay 1 en este momento), no hace falta aún una red virtual real entre máquinas (ésta la montaremos luiego)
Y kubernetes crea entre tanto una red similar a la de docker (dentro de mi máquina).
No obstante, le indico en que tramo de red va a trabajar la rfutura red, para que las IPs que se asignen a esos contenedores, sirvan en el futuro, cuando SI HAYA RED VIRTUAL ENTRE MAQUINAS.

Luego creare una red que trabajara en el rango: 10.10.0.0/16
Aún no la tengo... pero le informo a kubernetes que la tendré trabajando en ese tramo.


+---------------- red de la empresa: 172.31.0.0/16
|
||= 172.31.11.161-Nodo 1
||                   |- 10.10.0.100 -Pod: nginx
||                           |- Contenedor de nginx
||= 172.31.11.162-Nodo 2
||                   |- 10.10.0.101 -Pod: mariadb
||                           |- Contenedor de mariadb
||
||= 172.31.11.163-Nodo 3
 |
 | Red de kubernetes (red virtual, sobre la "física" de mis máquinas) 10.10.0.0/16

## Salida del kuadm init

Se me ha generado un fichero con los datos de conexión al cluster: /etc/kubernetes/admin.conf 
Ese fichero es leido por el programa kubectl (el cliente de kubernetes)
Pero kubectl lo busca en mi carpeta personal... dentro de .kube
Tengo que copiarlo allí

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.31.11.161:6443 --token sfj4cf.60g2jprg6g59nf0z \
        --discovery-token-ca-cert-hash sha256:528565df0ecd64feaf9e94ec3f5b0ae52aed86bb67e8d3417ff3748b4e9d7526 
        
## kubectl

Es el cliente de kubernetes. Nos permite hacer todo tipo de operaciones sobre el cluster.
La sintaxis es muy sencilla:

    $ kubectl create|apply|delete -f <FICHERO DE MANIFIESTO>
        create: Creará en el cluster todos los objetos definidos en el fichero
        apply: Creará o modificará en el cluster todos los objetos definidos en el fichero
        delete: Borrará todos en el cluster todos los objetos definidos en el fichero
    $ kubectl <VERBO> <TIPO DE OBJETO> <args opcionales>
    
ARGS OPCIONALES: 
    --namespace <NS> , -n <NS>
    --all-namespaces,
    -o wide                             INFORMACION EXTRA
    
VERBOS: Dependen del tipo de objeto

                                delete
                                get
                                describe
TIPOS DE OBJETO:

                                                            ALIAS
    namespace                                               namespaces ns
    node        
    pod                         logs | exec
    deployment                  scale                       
    statefulset
    daemonset
    secret
    configmap
    service                                                 services svc
    ingress
    
    
# Objetos de kubernetes

- Node:         Representan máquinas "físicas" que tenemos en el cluster
- Namespace:    Agrupación lógica de objetos dentro del cluster
- Pod:          Conjunto de contenedores que despliegan en el mismo host y escalan juntos.
                Comparten IP y pueden compartir volumenes locales       

# Estados de un pod

Un pod puede estar en varios estados:
- FAILED - CRASHLOOPBACK
- INITIALIZING
- READY
- PENDING                   Implica que el scheduler no ha localizado una máquina capaz de ejecutar esos pods

# En nuestro caso, tenemos un nodo UNICO

Esto en un cluster REAL NO ES VALIDO... no lo encontraremos nunca.
Por defecto, kubernetes NO PERMITE que NINGUN PROGRAMA que no sea un programa del plano de control
se instale en un nodo que tenga el rol: Control-plane

AQUI HAREMOS UN APAÑO! Le diremos a kubernetes que nos deje instalar cosas en ese nodo, aun siendo un nodo del plano de control.

EN UN CLUSTER REAL NI DE COÑA !

    $ kubectl taint node --all node-role.kubernetes.io/control-plane-
    # El menos al final implica que quito esa restriccion
    
    
---

# Uso de CPU y MEMORIA por los pods:

- Utilización de CPU:             4,00m
    Se mide en milicores: 1000 milicores es el equivalente a estar usando una cpu al 100%
                                                         o a estar usando 2 cpus al 50%

- Utilización de memoria:         16,68Mi
    16 q? En qué se mide? Mi? Mebibytes
        1 Gib = 1024 Mib 
        1 Mib = 1024 Kib
        1 Kib = 1024 bytes

        1 Gb = 1000 Mb... Antiguamente (25 años atrás... eran 1024)
