Exercício 2 – Servidor DHCP em Azure com Terraform e Ansible
Descrição
Este projeto corresponde ao Exercício 2 do trabalho final da unidade curricular de Administração de Sistemas.

O objetivo é criar e configurar automaticamente uma máquina virtual Linux na Microsoft Azure que desempenhe o papel de servidor DHCP, utilizando exclusivamente Terraform para a infraestrutura e Ansible para a configuração, sem qualquer configuração manual.

Não são armazenadas passwords nem credenciais sensíveis nos ficheiros do repositório.

Tecnologias Utilizadas
Terraform – Provisionamento da infraestrutura na Azure
Ansible – Configuração automática do servidor DHCP
Microsoft Azure – Plataforma cloud
Ubuntu Server 22.04 LTS – Sistema operativo da VM

Arquitetura Criada
O Terraform cria automaticamente:
Resource Group
Virtual Network
Subnet
Network Interface
Network Security Group
Máquina Virtual Linux (Ubuntu)

A autenticação SSH é feita exclusivamente por chave pública, sem passwords.


Usar o Terraform

Entrar na pasta do Terraform:

cd terraform

Inicializar o Terraform:

terraform init

Ver o plano de execução:

terraform plan

Criar a infraestrutura:

terraform apply

No final, o Terraform cria a VM e a rede necessária para o servidor DHCP.



Configuração do DHCP com Ansible
Atualizar o ficheiro inventory.ini com o IP privado ou IP público da VM (consoante o cenário de teste).

Executar o playbook:

cd ansible
ansible-playbook playbook.yml

O Ansible:
Instala o serviço DHCP
Aplica a configuração automaticamente
Garante que o serviço fica ativo

Testes
Uma máquina cliente pode ser criada na mesma subnet
O cliente obtém endereço IP automaticamente via DHCP
A comunicação é validada através de testes de rede (ex.: ping)
só pra deixar aqui amanhã colocamos no github
