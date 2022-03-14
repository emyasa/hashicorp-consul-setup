# Download and Install Consul
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update && sudo apt-get install consul

# Modify the default consul.hcl file
cat > /etc/consul.d/consul.hcl <<- EOF
data_dir = "/opt/consul"

client_addr = "0.0.0.0"

ui_config{
  enabled = true
}

server = true

bind_addr = "0.0.0.0"

bootstrap_expect=1
EOF

# Start Consul
systemctl start consul