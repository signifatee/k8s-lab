# скрипт для поднятия виртуалок и настройки k8s
./preflight.sh
cd terraform
tofu apply -auto-approve
sleep 30
cd ../ansible
ansible-playbook site.yml