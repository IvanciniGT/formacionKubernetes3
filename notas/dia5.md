# Deployment

Plantilla de pod + número de réplicas

# DaemonSet

Plantilla de Pod de la cuál Kubernetes montará un pod en cada nodo.

# StatefulSet

Plantilla de pod + número de réplicas + Plantillas de PVC (al menos 1)

Todos los productos de software que operan en cluster almacenando datos, los configuramos mediante STATEFULSET:
    - Indexador: ES, SOLR
    - BBDD: MariaDB, PostgreSQL, SQLServer, Oracle
    - Sistema de mensajería: KAFKA, RABBITMQ

---

# ElasticSearch

Es un indexador que opera en cluster de forma distribuida.

Distribuida? 
Voy a tener distintos componentes en la aplicación, dedicados a distintas tareas en sitios diferentes.

En un cluster de ES, tengo distintos tipos de nodos:
- MAESTROS (3)
- DATOS (2)
- INGESTA
- COORDINADORES
- ML
- ...

Esos nodos van a estar en comunicación entre si... Siempre y cuando se hayan unido en un cluster.
Antiguamente en ES los nodos daban un grito en la red: 
    Eh!!! hay alguien por ahñi que quiera formar parte de un cluster? (Broadcast)
Eso lo quitaron por los problemas que conllevaba.
Hoy en día el descubrimiento de nodos se hace mediante comunicaciones UNICAST.
Cada nodo se presenta formalmente a otro(s) nodos concretos.
- Si un nodo de ES A, conoce a un nodo de ES B, y el nodo B conoce al C, 
  el nodo B presenta A a C, para que llos también sean amiguitos.

Claro... esto hay que configurarlo.
Os imaginais que nodos son obligatorios al menos para poner en marcha un cluster? los MAESTROS

Y en kubernetes serán 3 pods... con un servicio por delante: BALANCEO:

Al pod DATA 1, le voy a pedir que se presenta a uno de los maestros... me importa a cuál?
    NO... en cuanto conozca a 1, ya se encarga ese le presentarle al resto de amiguis!
    Por tanto, en ES, en el fichero de configuración del DATA 1:  
        a_quien_te_presentas: maestros-servicio
            Ese servicio es una IP de balanceo que me llevará a alguno de los 3 maestros que tengo por detrás del servicio (en balanceo)
            A cuál? NPI, me da igual... a alguno, al que sea.
Al pod INGESTA 2, a quién le pido que se presente?
        a_quien_te_presentas: maestros-servicio
        Le importa a qué maestro conozca? NO... uno de ellos (el balanceo de nuevo aquí me va guay)
Al pod MAESTRO1, a quién le pido que se presente?
        a_quien_te_presentas: maestros-servicio             ? Me vale esto mismo? NO... por qué?
            Porque si tengo la mala suerte de que el balanceo me conecte con él mismo... 
                El MAESTRO 1 se pone a tener una conversación de besugos consigo mismo... y no forma cluster.
        a_quien_te_presentas: maestro2.maestros-servicio    maestro3.maestros-servicio            
Al pod MAESTRO2
        a_quien_te_presentas: maestro3.maestros-servicio            
    
En la realidad no lo hacemos así:
Al pod MAESTRO?
        a_quien_te_presentas: maestro1.maestros-servicio, maestro2.maestros-servicio
        Y cuando hable consigo mismo... pasa del tema.

Una vez formado el cluster, ya puedo pedir datos a cualquier nodo... Eso da igual... pero el cluster hay que formarlo... y para eso me hace falta lo anterior.
Y ésto es lo que nos resuelven los servicesName de los StatefulSet... Darnos la posibilidad de atacar a pods concretos de un StatefulSet.

---

# Etiquetado de objetos de kubernetes

Todo objeto de kubernetes puede tener etiquetas: LABELS
Incluso puedo ponerle esas etiquetas a posteriori:
 $ kubectl label TIPO_OBJETO NOMBRE_OBJETO ETIQUETA=VALOR
 
Kubernetes de serie, añade un montón de etiquetas a los nodos:

    beta.kubernetes.io/arch=amd64           # Arquietectura del micro que tengo en ese nodo: amd64, arm
    kubernetes.io/arch=amd64

    beta.kubernetes.io/os=linux             # SO del nodo
    kubernetes.io/os=linux

    kubernetes.io/hostname=ip-172-31-11-161                     # Nombre del nodo
    node-role.kubernetes.io/control-plane=                      # Si el nodo es un nodo del plano de control
    node.kubernetes.io/exclude-from-external-load-balancers=    # Si cuando kubernetes configure servicios de tipo LoadBalancer...
                                                                # Y por ende un balanceador de carga externo, debe meter a este nodo en balanceo.
                                                                # Si pongo la etiqueta se excluye del balanceo.

Yo puedo poner mis propias etiquetas extra a los nodos.

# Afinidades

Nos permiten a los desarrolladores influir en el Scheduler, cuando vaya a tomar la decisión de en qué máquina debe alojarse un pod concreto.

Escenarios donde esto me pueda ser de utilidad:
- Monto 800 páginas web en mi casa...
    - Voy a tener un mariadb-galera en cluster para todas ellas... Así solo tengo que operar 1 BBDD (Backups... etc. se me simplifican)
      Lo monto en unas máquinas gordas.
    - Monto 10 RaspberryPi para correr el WP... y meto las rspies en el cluster de kubernetes.
        Son baratas
        Gastan nada de electricidad
        Tienen potencia suficiente
        Si se rompe una la tiro a la basura y compro otra
  Eso si... me tengo que asegurar que los pods de la BBDD vayan a las máquinas gordas y los WP a las raspies.
  NO TODAS LAS MAQUINAS DE UN CLUSTER TIENEN POR QUE SER IGUALES
- Monto una aplicación de reconicimiento de imágenes: Identificación de personas por su foto en un aeropuerto.
  Esa app para funcionar guay qué necesita? Deep Learning: una GPU bestial! de las que cuestan muuchos billetes... no una 7700
  Si tengo un cluster de Kubernetes con 20 nodos... no en todos tengo esa GPU... a lo mejor solo en 2.
  Necesito que mi pod vaya a una máquina que tenga una de esas GPUs guays.
- Tengo 3 nodos... y quiero poner 3 replicas de mi app A. Si no le indico nada a kubernetes, corro el riesgo de que el scheduler haga algo como:
    nodo1           pod1A, pod2A, pod3A
    nodo2           pod1B, pod2B, pod3B
    nodo3           pod1C, pod2C, pod3C
  Me interesa eso? o eso:
    nodo1           pod1A, pod1B, pod1C Si se cae una máquina sigo dando TODOS los servicios
    nodo2           pod2A, pod2B, pod2C
    nodo3           pod3A, pod3B, pod3C

Hay muchos escenarios donde me interesa influenciar al scheduler para que haga algo que me interese más ... o que necesite!

Y para ello tenemos las afinidades.
En kubernetes hay 3 tipos de afinidades:    

## Afinidades a nivel de nodo  

Hay 3 sintaxis diferentes que podemos usar en Kubernetes: 

### nodeName

En cualquier pod o plantilla de pod, podemos poner dentro de su spec:
    nodeName: <El nombre de un nodo>
    
Esto no se usa.... no me la voy a jugar a 1 nodo concreto... si se cae el nodo me quedo sin servicio.
Casos muy excepcionales podrían requerir algo como esto.

### nodeSelector

En cualquier pod o plantilla de pod, podemos poner dentro de su spec:

    nodeSelector:
        etiqueta: valor         # que debe estar asignada en el nodo.

Me permite filtrar los nodos que podrían alojar al pod.
Podría poner varias etiquetas-

    nodeSelector:
        gpu: guay

### nodeAffinity

Esta sintaxis es la más potente... aunque la más compleja de escribir (al final es un copia pega...)
En todas las affinities (a nivel de pod, de nodo, o antiafinidades), podremos configurarlas de 2 tipos: requeridas o preferidas

    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution: # se aplica solamente por el scheduler... no hay otra opción
            nodeSelectorTerms:
            - matchExpressions:
              - key: gpu
                operator: Exist # In NotIn Exists DoesNotExists Gt Lt
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            preference:
              matchExpressions:
              - key: gpu
                operator: In
                values:
                - gpu-tipo-1
                - gpu-tipo-2
          - weight: 1
            preference:
              matchExpressions:
              - key: gpu
                operator: In
                values:
                - gpu-tipo-3

Si no haya disponible ni máquinas con gpu-tipo 1 ni 2 ni 3... en otra que tenga gpu
Y si la hay con gpu-tipo 1 o 2, mejor que con tipo 3

## Afinidades a nivel de pod y Antiafinidades a nivel de pod

La sintasis, solo hay una, es similar a la de nodeAffinity.

    spec:
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - database
            topologyKey: kubernetes.io/hostname


Estoy pidiendo al scheduler que este pod se monte en una máquina (nodo) donde ya 
exista un pod con la etiqueta app: database, que que mi pod está generando afinidad con él.

            YA TIENEN                       DONDE PODRIA IR un nuevo pod, con la especificacion anterior?
    nodo1   app:database                            √
    nodo2   app:web-server                          x
    nodo3   app:database app:web-server             √
    nodo4                                           x

    POD 1
    spec:
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: NotIn
                values:
                - database
            topologyKey: kubernetes.io/hostname

    POD 2
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - database
            topologyKey: kubernetes.io/hostname

Son equivalentes las anteriores? SI... parece... pero NO... ni parecidas

            YA TIENEN                       DONDE PODRIA IR POD1?   DONDE PODRIA IR EL POD2?
    nodo1   app:database                            x                       x
        kubernetes.io/hostname: nodo1
    nodo2   app:web-server                          √                       √
        kubernetes.io/hostname: nodo2
    nodo3   app:database app:web-server             √                       x
        kubernetes.io/hostname: nodo3
    nodo4                                           x                       √
        kubernetes.io/hostname: nodo4
    
POD AFFINITY GENERA BUENAS VIBRAS (ATRACCION) con PODS QUE CUMPLAN LA CONDICION... 
    lo que permite al pod ponerse en cualquier máquina que comparta el valor de una etiqueta topologyKey con la máquina que tenga esos pods
POD ANTIAFFINITY GENERA MALAS VIBRAS (REPULSION) con POD QUE CUMPLAN LA CONDICION...
    lo que evita al pod ponerse en cualquier máquina que comparta el valor de una etiqueta topologyKey con la máquina que tenga esos pods

    POD 3
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - database
            topologyKey: zona 

                            YA TIENEN DENTRO        DONDE PUEDE IR EL POD 3?
    nodo1(zona=A)       app: database**                         x
    nodo2(zona=A)       app: web-server                         x

    nodo3(zona=B)       app: database**                         x
    nodo4(zona=B)                                               x

    nodo5(zona=C)       app: web-server                         √
    nodo6(zona=C)                                               √

    nodo7(zona=D)                                               √
    nodo8(zona=D)                                               √

El topologyKey por tanto lo entendemos con EL NIVEL al que genero la afinidad o antiafinidad

    En nuestro ejemplo del POD 1 y 2, generábamos afinidad a nivel de MAQUINA (kubernetes.io/hostname)
    En nuestro ejemplo 3, generamos antiafinidad con aquellas máquinas de la misma ZONA que las que ya tienen un database
        Genero antiafinidad con la ZONA , por en esa zona haber un pod con el que genero antiafinidad.

Yo os he dicho que las ANTIAFINIDADES las usamos siempre... en TODO despliegue... repito en TODO despliegue.
Por qué? cuál es el caso de uso para que esto sea así?

    En cualquier Deployment o Statefulset donde replicas > 1, 
    quiero que esos pods que se van a generar (replicas) se ubiquen en el mismo host? PREFIERO que no.

Siempre generamos una antiafinidad (normalmente preferida) con pods del mismo tipo

    kind: Deployment
    ...
    spec:
        ...
        replicas: 5    # Esto aplica a cualquier número  > 1
        template:
            ...
            metadata:
                label: 
                    app: yo                                                 # REFERENCIA
            spec:
              affinity:
                podAntiAffinity:
                  preferedDuringSchedulingIgnoredDuringExecution:
                  - weight: 100
                    podAffinityTerm:
                      labelSelector:
                        matchExpressions:
                          - key: app
                            operator: In
                            values:
                            - yo                                            # REFERENCIA
                      topologyKey: kubernetes.io/hostname




Tengo un cluster con 2 zonas geográficas (como teneis vosotros allí)

En ese cluster quiero desplegar la app1. quiero un pod en cada zona... que no me ponga los 2 pods en la misma zona
Con antiafinidad a nivel de zona: topologyKey: zone

RESUMEN: LAS AFINIDADES ME PERMITEN A MI DESARROLLADOR INFLUENCIAR AL SCHEDULER en la ubicación de los pods.

# Tintes y Tolerancias

Es un concepto complementario al de las afinidades.
Las afinidades ME PERMITEN A MI DESARROLLADOR INFLUENCIAR AL SCHEDULER en la ubicación de los pods.
Con ellas por ejemplo, un desarrolaldor (o quien sea que quiera desplegar una app en un cluster)
puede pedir al scheduler que su app sea desplegada en una máquina con GPU.

Pero... la pregunta es:
> Servirían las afinidades para lo contrario?
Es decir, para evitar que un pod que no necesita GPU se instale un una máquina con GPU?

Pero... que yo recuerde... las antiafinidades eran a nivel de POD... no de nodo.
No habría forma.
Podría retorcer el sistema:
- Las máquinas que no tengan gpu, les pongo etiqueta: gpu=False
  Y las que si, les pongo gpu=gpu-tipo-1 o gpu=gpu-tipo-2
  Aunque esto me obligaría a:

    Los que quieran desplegar en una máquina con GPU deberían poner 

    spec:
          affinity:
            nodeAffinity:
              requiredDuringSchedulingIgnoredDuringExecution: # se aplica solamente por el scheduler... no hay otra opción
                nodeSelectorTerms:
                - matchExpressions:
                  - key: gpu
                    operator: NotIn
                    values:
                    - False
    
    Y lo que es peor:    
    Los que no necesiten desplegar en una máquina con GPU deberían poner 

    spec:
          affinity:
            nodeAffinity:
              requiredDuringSchedulingIgnoredDuringExecution: # se aplica solamente por el scheduler... no hay otra opción
                nodeSelectorTerms:
                - matchExpressions:
                  - key: gpu
                    operator: In
                    values:
                    - False
    
    Le veís sentido a esto? QUE TODOS (500 tios) que no necesitan una GPU lo tengan que explicitar?
    Lo van a hacer? Se van a acordar? Les puedo obligar a eso?
    Y si tampoco necesitan una máquina con discos locales ultrarapidos? también?
    Y cuantas cosas más tienen que negar?
    
    Yo dire lo que necesito... no tiene ningún sentido en el mundo decir lo que no necesito.
    Voy a basar mi cluster de kubernetes en la mera confianza que tenga en gente que ni conozco.. en que hagan bien su trabajo?
    De qué estamos hablando?

LAS AFINIDADES NO VALEN PARA ESTO!

Para eso están los TINTES:
Las afinidades PERMITEN A QUIEN QUIERE DESPLEGAR UNA APP EN UN CLUSTER INFLUENCIAR AL SCHEDULER en la ubicación de los pods.
Los tintes ME PERMITEN A MI ADMINISTRADOR DEL CLUSTER hacer que NODOS concretos RECHACEN a ciertos pods.

Por ejmplo:
- Este nodo, donde he montado una GPU, rechazará a cualquier pod, que expresamente no haya dicho que requiere GPU

Son conceptos complementarios... que muchas veces usamos conjuntamente.
- Quiero este despliegue en una máquina con GPU (AFINIDAD)
- Quiero que esta máquina rechace a todo aquel que no diga que requiere GPU
Las 2 reglas me dan la buena politica.

Pero los tintes funcionan de una forma muy particular.
Al igual que con las etiquetas, podemos teñir nodos... o desteñirlos

    $ kubectl taint node NODO tinte:efecto         ASI TIÑO 
    $ kubectl taint node NODO tinte:efecto-        ASI DESTIÑO

    efecto.   NoSchedule, PreferNoSchedule, NoExecute(tiene una finalidad distinta)

Cuando nodo es teñido, rechazará todos aquellos pods que explicitamente no hayan dicho que toleran ese tinte.
Y esas son las tolerancias... que se detallan a nivel de pod, igual que las afinidades.

# Vamos a empezar hablando del efecto: NoSchedule, PreferNoSchedule

Cuando tiño a un nodo con ese efecto, el scheduler evita poner en ese nodo a cualquier pod que expresamente no soporte ese tinta en ese efecto.

    $ kubectl taint node nodo178 gpu:tipo-1:NoSchedule
        > Al scheduler le digo que NoSchedule (no planifique) un pod en este nodo si no soporta gpu:tipo-1
    
El scheduler rechazará a cualquier pod que no soporte ese tinte.
Para que un pod soporte ese tinte, pondríamos una tolerancia:

    POD 4
    spec:
        tolerations: 
        - key: "gpu"
          operator: "Equal"
          value: "tipo-1"
          effect: "NoSchedule"
          
        > Le digo al Scheduler que el pod soporta el NoSchedule de ese tinte: gpu:tipo-1
          No me importa si el nodo ha dicho esto... lo soporto... lo tolero.

    Al soportar el POD 4 el tinte del nodo 178, el schedule podría elegir al nodo 178 para el despliegue del pod 4... no se descarta.
        En cualquier caso, el schueduler podría meter el pod4 en otro nodo... que no tuviera GPU. ---> Eso lo consigo con una AFINIDAD
    Para un pod que no tuviera esa toleración, el scheduler no elegiría nunca el nodo 178 para el despliegue de ese pod.

Al escribir esto, le indicamos al Scheduler que adminitimos ese tinte. Y el scheduler nos podrá ubicar en un nodo que tenga el tinte.
Esto no quita que también me podría ubicar en nodos que no tengan ese tinte. CUIDADO !!!!!
Para asegurarme que me pone en uno de esos:

    $ kubectl label node nodo178 gpu=tipo-1
        
    spec: 
        nodeSelector:
            gpu: tipo-1

    Esto va a hacer que el scheduler busque para el pod una máquina con gpu tipo-1.
    Pero la máquina tiene un tinte... y rechaza pods. El pod debe soportar (tolerar) el tinte.

# Efecto: NoExecute 

Esto se usa para algo diferente. 
Literalmente lo que significa es que allí no se puede ejecutar un pod... Si el pod ya está allí es evacuado a otro nodo.
Lo usan los administradores de sistemas para evacuar nodos, por ejemplo antes de la actualización del osftware en el nodo de Kubernetes.
- Quiero actualizar la versión de kubernetes en el nodo 17
- Le aplico un tinte NoExecute
- Todos los pods son evacuados a otros nodos
- Espero un poquito a que eso ocurra...
- Actualizo el nodo
- Le quito el tinte

Los pods también pueden soprtar efectos NoExecute... en este charco no nos metemos...no se usa.

---

# Horizontal pods... recursos

pod 1 al 60%
pod 2 al 40%

en este caso estaba yo ya configurando escalado.. que me monte otro... tiene sentido tan pronto?
No me queda mucha máquina vacía aún?

El problema no es SOLO la capacidad de trabajo (ESCALABILIDAD)... hay un problema previo MAS IMPORTANTE: HA
Y la HA cuesta una pasta de COJONES ! LO ASUMIMOS en los entornos de prod.

Qué pasa en ese escenario si se cae el POD 2? Kubernetes va a abrir otro... pero eso le lleva tiempo
Quizás solo 10 segundos...
Pero en esos 10 segundo, toda la carga de trabajo del pod 2 pasa al pod 1... puede soportarla? NO
El pod 1 se cae también... CUIDADO CON LAS CAIDAS EN CASCADA DE UN CLUSTER!

Muchas apps en la casa las tenis configuradas con 4 máquinas al 25%.... y que si se caen 3 máquinas todo siga funcionando.


---

# DEVOPS

Devops nunca jamás ha sido un perfil... lo cual no quita que hoy en día se use como un perfil.
De hecho cada empresa en el mundo IT usa la palabra DEVOPS para referirse a algo diferente.

Devops es una cultura en pro de la automatización.
Para automatizar necesito herramientas:
    - Desarrolladores ahora automatizan el empaquetado de sus aps: docker, maven, gradle, msbuild
    - Tester ahora automatizan la ejecución de pruebas: JMeter, Selenium, JUnit, SoapUI, POstman
    - Los administardores de sistema ahora automatizan: creaciñon de entornos, configuraciones:
        Terraform, Ansible, Puppet, Vagrant
Ninguno de ellos es un devops. Ahora lo que tengo es:
     Un desarrollador que sabe automatizar sus cosas
     Un tester que sabe automatizar sus cosas
     Un sysadmin que sabe automatizar sus cosas.
Hay una muy fea tendencia en algunas empresas a llamar devops al sysadmin que automatiza.

En el mundo DEVOPS si hay un perfil nuevo... una tarea nueva que antes no se hacía:
CONFIGURAR JENKINS o similares (que ofrecn una automatización de segundo nivel)
Antes no usábamos Jenkins, Gitlab CI/CD, Azure DEVOPS... Travis, BAmboo, TeamCity
Me hace falta un tio nuevo que sepa de TODO ESO.. un poquito... el no va a escribir las automatizaciones.

Eso es a lo que algunas (por suerte) compañías si le estan llamando devops... que si tiene sentido!
