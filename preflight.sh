source .env

if [[ $(grep -c vmx /proc/cpuinfo) -gt 0 ]]; then
    echo "---------- VMX support is available. ----------" 
else
    echo "!!!------- VMX support is not available. -------!!!"
    exit 2
fi

if [[ $(kvm-ok) ]]; then
    echo "---------- KVM is available. ----------" 
else
    echo "!!!------- KVM is not available. -------!!!"
    exit 2
fi

echo "~~~~~~~~~~ Installing dependencies... ~~~~~~~~~~"
apt-get update
apt-get autoremove -y
apt-get clean -y
apt-get install -y qemu-system-x86 libvirt-daemon-system libvirt-clients bridge-utils virt-manager virtinst cloud-utils
echo "~~~~~~~~~~ Done ~~~~~~~~~~"

echo "~~~~~~~~~~ Adding user to libvirt and kvm groups... ~~~~~~~~~~"
usermod -a -G libvirt,kvm $USER
echo "~~~~~~~~~~ Done ~~~~~~~~~~"

if [[ $(cat /sys/kernel/mm/ksm/run) -eq 1 ]]; then
    echo "---------- KSM is enabled. ----------" 
else
    echo "!!!------- KSM is not enabled. -------!!!"
    exit 2
fi

if [[ $(virsh uri) == "qemu:///system" ]]; then
    echo "---------- Libvirt is running. ----------" 
else
    echo "!!!------- Libvirt is not running. Logout or restart you pc and start again -------!!!"
    exit 2
fi

if [[ $(df / | awk 'NR==2 {print int($4/1024)}') -gt 150000 ]]; then
    echo "---------- There is enough disk space. ----------" 
else
    echo "!!!------- There is not enough disk space. -------!!!"
    exit 2
fi

#cd /var/lib/libvirt/images
if [[ $(qemu-img info /var/lib/libvirt/images/noble-server-cloudimg-amd64.img) ]]; then
    echo "---------- Cloud image is available. ----------" 
else
    echo "~~~~~~~~~~ Downloading cloud image... ~~~~~~~~~~"
    wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img -P /var/lib/libvirt/images
    echo "~~~~~~~~~~ Done ~~~~~~~~~~"

    if [[ $(qemu-img info /var/lib/libvirt/images/noble-server-cloudimg-amd64.img) ]]; then
        echo "---------- Cloud image is available. ----------" 
    else
        echo "!!!------- Cloud image is not available. -------!!!"
        exit 2
    fi
fi

if [[ $(virsh net-list --all | awk 'NR==4 {print $1}') == "k8s-lab" ]]; then
    echo "---------- k8s-lab network is available. ----------" 
else
    echo "~~~~~~~~~~ Creating k8s-lab network... ~~~~~~~~~~"
    virsh net-define terraform/k8s-lab-net.xml
    virsh net-start k8s-lab
    virsh net-autostart k8s-lab
    echo "~~~~~~~~~~ Done ~~~~~~~~~~"
    if [[ $(virsh net-list --all | awk 'NR==4 {print $1}') == "k8s-lab" ]]; then
        echo "---------- k8s-lab network is available. ----------" 
    else
        echo "!!!------- k8s-lab network is not available. -------!!!"
        exit 2
    fi
    echo "!!!------- k8s-lab network is not available. -------!!!"
    exit 2
fi

if [[ $(cat /etc/hosts | grep "k8s-api.lab.local") ]]; then
    echo "---------- Hosts are already added to /etc/hosts. ----------" 
else
    echo "~~~~~~~~~~ Adding hosts to /etc/hosts... ~~~~~~~~~~"
    sudo tee -a /etc/hosts << 'HOSTS'
192.168.100.11  cp-1 k8s-api.lab.local
192.168.100.21  worker-1
192.168.100.22  worker-2
192.168.100.23  worker-3
HOSTS

    echo "~~~~~~~~~~ Done ~~~~~~~~~~"
    if [[ $(cat /etc/hosts | grep "k8s-api.lab.local") ]]; then
        echo "---------- Hosts are added to /etc/hosts. ----------" 
    else
        echo "!!!------- Hosts are not added to /etc/hosts. -------!!!"
        exit 2
    fi
fi

echo "~~~~~~~~~~ Installing python3-kubernetes... ~~~~~~~~~~"
sudo apt install python3-kubernetes -y
python3 -c 'import kubernetes; print(kubernetes.__version__)'
echo "~~~~~~~~~~ Done ~~~~~~~~~~"

exit 0



