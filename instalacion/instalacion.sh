# Preparativos

## Desinstalar docker ya que en este caso nos viene preinstalado
sudo apt purge docker-ce -y
sudo apt purge containerd.io -y
sudo apt autoremove -y
## Desactivar la swap. Kubernetes no admite swap
sudo swapoff -a # Desactivar la swap en el arranque de maquina actual
### Al reiniciar la máquina ese cambio habría que volver a aplicarlo.
### Para evitar eso tocamos el fichero donde se declara la swap /etc/fstab
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
## La máquina, AWS nos la ha dado con un HDD muy pequeño por defecto.
sudo growpart /dev/nvme0n1 1
sudo resize2fs /dev/nvme0n1p1
## Instalamos el gestor de contenedores que usará kubernetes: CRIO
### Crio tiene sus dependencias
sudo apt install apt-transport-https ca-certificates curl gnupg2 software-properties-common -y
### Crio requiere un par de módulos activos en el kernel de Linux
### Son para la red virtual de los contenedores
sudo su -
echo "overlay
br_netfilter" > /etc/modules-load.d/k8s_crio.conf
### Instalamos crio... Lo primero dar de alta los repos de CRIO en ubuntu para apt
### Definir las versiones de CRIO que queremos
export OS=xUbuntu_22.04
export CRIO_VERSION=1.27
export kubernetes_version=1.28.0

### Damos de alta los repos y sus claves
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | sudo apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /"| sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list
apt update # Lee los nuevos repos en busca del software que contienen

### En este momento ya estamos en disposición de instalar CRIO
apt install cri-o cri-o-runc -y
apt install cri-tools -y

### Creamos un fichero de configuración de CRIO... donde indicamos la condifguración de red virtual que usará crio para los contenedores
echo "net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-ip6tables=1" > /etc/sysctl.d/k8s_crio.conf
sysctl -p  /etc/sysctl.d/k8s_crio.conf # Aplicamos la configuración

### Reiniciar y activar el servicio de crio. Y confirmar que funciona guay
systemctl enable crio
systemctl restart crio
### systemctl status crio
crictl info
### Me piro de jefe supremo
exit

# Instalacion de Kubernetes
## Lo que instalamos son 3 comandos(paquetes) kubelet, kubeadm, kubectl 
## Lo primero, los repos
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
## A instalar
sudo apt install kubelet kubeadm kubectl  -y

## NOTA: Hasta este punto, lo haríamos en todas las máquinas del cluster que vayamos a crear

# Crear un cluster de Kubernetes: ESTO SE EJECUTA SOLO EN UN NODO QUE VAYA A TENER EL ROLE DE CONTROLPLANE
sudo kubeadm init --pod-network-cidr "10.10.0.0/16" --upload-certs

## Copiamos el archivo de conexión al cluster en nuestra carpeta de usuario, para que kubectl lo detecte y poder empezar a hablar con nuestro cluster de kubernetes.
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Instalar cosas adicionales

## Montar el driver de red virtual para los pods: ELEGIMOS CALICO:
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml

## Queremos montar el dashboard gráfico de kubernetes
### Es una herramienta oficial, que por defecto no se despliega en un cluster.
### La herramienta, si la voy a usar para echar un ojo al cluster, está bien.
### NUNCA DEBO USAR ESTA HERRAMIENTA PARA HACER CAMBIOS EN EL CLUSTER.
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

## Creo un usuario para el dashboard:
kubectl apply -f curso/instalacion/usuario-dashboard.yaml 

## Obtengo el token (contraseña) generada automaticamente para el usuario:
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d

## Montamos metric server... un programa oficial de kubernetes que captura metricas de CPU y RAM de los pods/contenedores
wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl apply -f components.yaml