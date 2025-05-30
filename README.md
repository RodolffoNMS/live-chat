# 💬 LiveChat Catalisa

 Sistema de bate-papo em tempo real com moderação automática, persistência de mensagens e arquitetura escalável na AWS.

 ---

 ## ✨ Visão Geral

 O **LiveChat Catalisa** é uma aplicação de chat em tempo real desenvolvida com Spring Boot, WebSockets (STOMP), frontend responsivo e backend serverless na AWS. O sistema monitora o conteúdo das mensagens, bloqueia informações sensíveis ou linguagem inadequada, notifica os envolvidos e registra incidentes para auditoria e compliance.

 ---

 ## 🏗️ Arquitetura

 ![Arquitetura](https://raw.githubusercontent.com/RodolffoNMS/live-chat/refs/heads/develop/src/main/resources/static/img/Arquitetura.png)

 - **Frontend:** HTML5, Bootstrap 5, JavaScript (STOMP.js)
 - **Backend:** Spring Boot + WebSocket (STOMP)
 - **Persistência:** AWS Lambda + DynamoDB
 - **API Gateway:** AWS API Gateway (REST e WebSocket)
 - **Infraestrutura:** ECS Fargate, NLB, Terraform

 ---

 ## 🚀 Funcionalidades

 - Mensagens em tempo real via WebSocket
 - Moderação automática de conteúdo (StackSpot Quick Command)
 - Persistência de mensagens no DynamoDB
 - Recuperação de histórico de mensagens
 - Interface responsiva e intuitiva
 - Deploy automatizado via Terraform

 ---

 ## 📦 Instalação Local

 ### Pré-requisitos
 - Java 17+
 - Maven 3.8+
 - Docker (opcional, para rodar localmente)

 ### Passos
 ```bash
 git clone https://github.com/seu-usuario/live-chat.git
 cd live-chat
 mvn clean package
 java -jar target/live-chat-0.0.1-SNAPSHOT.jar
 ```
 Acesse: [http://localhost:8080](http://localhost:8080)

 ---

 ## ☁️ Deploy na AWS

 O deploy é feito via **Terraform**. Certifique-se de ter as credenciais AWS configuradas.

 ```bash
 cd infra/
 terraform init
 terraform apply
 ```
 Isso irá provisionar:
 - VPC, Subnets, NAT, Internet Gateway
 - ECS Cluster + Fargate Service
 - NLB (Network Load Balancer)
 - API Gateway (WebSocket e REST)
 - DynamoDB para persistência
 - Lambdas para salvar e recuperar mensagens

 ---

 ## 🧩 Como Funciona

 1. **Usuário conecta** via WebSocket (`/livechat`)
 2. **Envia mensagem** → Backend Spring Boot recebe e publica no tópico `/topics/livechat`
 3. **Mensagem é salva** via chamada REST para Lambda (API Gateway) → DynamoDB
 4. **Moderação**: Lambda executa Quick Command StackSpot para censura automática
 5. **Frontend** recebe mensagens em tempo real e exibe na interface
 6. **Histórico**: Ao conectar, frontend carrega últimas mensagens via REST

 ---

 ## 🛡️ Segurança & Compliance

 - Moderação automática de mensagens (censura de termos sensíveis)
 - Logs de auditoria no CloudWatch
 - IAM Roles restritivas para recursos AWS

 ---

 ## 🛠️ Tecnologias Utilizadas

 - Java 17, Spring Boot 3
 - WebSocket (STOMP)
 - AWS Lambda, DynamoDB, API Gateway, ECS Fargate, NLB
 - Terraform
 - Bootstrap 5, HTML5, JS

 ---

 ## 📝 Exemplo de Uso

 1. Digite seu usuário e clique em **Conectar**.
 2. Envie mensagens no campo inferior.
 3. Veja as mensagens em tempo real na tabela.
 4. Desconecte quando desejar.

 ---

 ## 🧑‍💻 Contribuindo

 1. Faça um fork do projeto
 2. Crie uma branch: `git checkout -b minha-feature`
 3. Commit suas mudanças: `git commit -m 'feat: minha nova feature'`
 4. Push para a branch: `git push origin minha-feature`
 5. Abra um Pull Request

 ---

 ## 🏷️ Badges

 ![Java](https://img.shields.io/badge/Java-17-blue)
 ![Spring Boot](https://img.shields.io/badge/Spring_Boot-3.4.5-brightgreen)
 ![AWS](https://img.shields.io/badge/AWS-Cloud-orange)
 ![Terraform](https://img.shields.io/badge/Terraform-IaC-purple)
