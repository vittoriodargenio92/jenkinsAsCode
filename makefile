DATA_FOLDER="data"
DATA_JENKINS_DOCKER_FOLDER="${DATA_FOLDER}/jenkins_docker_certs"
DATA_JENKINS_HOME_FOLDER="${DATA_FOLDER}/jenkins_home"
DATA_JENKINS_AS_CODE_FOLDER="${DATA_FOLDER}/jenkinsAsCode"

# data-volumes
init-data:
	if [ ! -d ${DATA_FOLDER} ]; then mkdir ${DATA_FOLDER}; fi
	if [ ! -d ${DATA_JENKINS_DOCKER_FOLDER} ]; then mkdir ${DATA_JENKINS_DOCKER_FOLDER}; fi
	if [ ! -d ${DATA_JENKINS_HOME_FOLDER} ]; then mkdir ${DATA_JENKINS_HOME_FOLDER}; fi
	if [ ! -d ${DATA_JENKINS_AS_CODE_FOLDER} ]; then mkdir ${DATA_JENKINS_AS_CODE_FOLDER}; fi
	chown -R 1000:1000 ${DATA_FOLDER}

clean-data:
	rm -rf data

# terraform
terraform-init:
	terraform init
terraform-apply:
	terraform apply -auto-approve
terraform-destroy:
	terraform destroy -auto-approve
terraform-clean:
	rm -rf .terraform/ .terraform* terraform*

# ngrok
ngrok-start:
	ngrok config add-authtoken ${NGROK_TOKEN}
	ngrok http 8080 &
ngrok-stop:
	ps uax | awk '/ngrok/{print $$2}' | head -1 | xargs kill -9

# jenkins
jenkins-initialAdminPassword:
	docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
jenkins-url:
	curl -s localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url'


deploy: terraform-init terraform-apply

update: terraform-apply

destroy: terraform-destroy terraform-clean

