virsh destroy cp-1                                                                                                                                                   ─╯
virsh undefine cp-1 --remove-all-storage

tofu destroy && tofu apply 

df / | awk 'NR==2 {print int($4/1024)}'

# проверка vm внутри
cloud-init status --long
ip -4 a
ip r
ping 8.8.8.8
systemctl status qemu-guest-agent
sudo cloud-init schema --system

tofu state mv 'libvirt_domain.cp1' 'libvirt_domain.node["cp-1"]'                                                                                                     ─╯
tofu state mv 'libvirt_volume.cp1' 'libvirt_volume.node["cp-1"]'
tofu state mv 'libvirt_cloudinit_disk.cp1' 'libvirt_cloudinit_disk.node["cp-1"]'
tofu plan     # должен показать "No changes" по этим ресурсам

ssh-keygen -f '/home/ques/.ssh/known_hosts' -R '192.168.100.11'

terraform apply -replace='libvirt_domain.node["worker-1"]'

ansible --version | grep 'config file'
ansible-playbook site.yml --list-tasks
ansible-playbook playbooks/99-reset.yml --limit worker-3 

ansible-inventory --graph
ansible-inventory --host cp-1 
ansible all -m ping

--check              # dry-run
--diff               # показать различия в файлах
--limit worker-3     # только один хост
--tags containerd    # только помеченные задачи
--start-at-task "Задать параметры ядра"
--step               # спрашивать подтверждение перед каждой задачей
-v / -vv / -vvv      # подробность; -vvv показывает SSH-команды



sudo kubeadm init phase preflight --config /etc/kubernetes/kubeadm-config.yaml
sudo kubeadm config images pull --config /etc/kubernetes/kubeadm-config.yaml
sudo crictl images

sudo kubeadm certs check-expiration


sudo kubeadm token create --print-join-command

cilium status
cilium connectivity test