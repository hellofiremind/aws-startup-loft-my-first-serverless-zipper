export CWD=$(pwd)

deployDocker() {
  TF_STATE=$(cat ${CWD}/infrastructure/terraform-state.json)

  ACCOUNTID=$(aws sts get-caller-identity | jq -r ".Account")
  aws ecr get-login-password | docker login --username AWS --password-stdin $(aws sts get-caller-identity | jq -r ".Account").dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
  ECR_URL=$(echo ${TF_STATE} | jq -r '.ecr_repository_url')

  docker build -t ${ECR_URL}:latest -f ./src/ecs/Dockerfile .
  docker tag ${ECR_URL}:latest ${ECR_URL}:latest
  docker push ${ECR_URL}:latest
}

restartTasks() {
  TF_STATE=$(cat ${CWD}/infrastructure/terraform-state.json)

  CLUSTER=$(echo ${TF_STATE} | jq -r '.ecs_cluster')

  tasks=$(aws ecs list-tasks --cluster $CLUSTER | jq -r '.taskArns | map(.[40:]) | reduce .[] as $item (""; . + $item + " ")')

  for task in $tasks;
  do
    aws ecs stop-task --task $task --cluster $CLUSTER
    sleep 1
  done
}

deployDocker
restartTasks
