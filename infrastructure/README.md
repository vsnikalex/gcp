# DevOps to Infrastructure Engineer

## Apply Terraform configuration locally
```bash
# it is assumed that SSH key preliminary generated 
# private key stored in ~/.ssh/gcp_rsa
# public key located in terraform/secret project folder and added to Git
terraform apply
```

## Run Ansible scripts
```bash
# download sources (given that the VMs SSH key added to GitHub)
git clone git@github.com:gridu/GCP_vnikolaev.git

# Test scripts
/usr/local/bin/ansible-inventory --list -i task-inventory.gcp.yml
/usr/local/bin/ansible -i task-inventory.gcp.yml all -m ping

# Apache installation script
/usr/local/bin/ansible-playbook -i task-inventory.gcp.yml task-apache.yml

# check that load balancer is working: perform multiple requests, different hostnames must be displayed
curl [LOAD_BALANCER_IP]
```
