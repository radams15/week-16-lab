#!/bin/bash

export AWS_REGION=eu-west-2
export AWS_DEFAULT_REGION=eu-west-2

if ! aws sts get-caller-identity
then
    echo >&2 "aws creds not working"
    exit 2
fi


readonly STUDENT_NAME="rhys-adams"

readonly STACK_NAME="${STUDENT_NAME}-vpc-1"
readonly TEMPLATE_FILE="$(dirname "${BASH_SOURCE[0]}")/templates/template.yml"
readonly AWS_DEFAULT_REGION="eu-west-2"
readonly USER_DATA_SCRIPT=app-user-data.sh
readonly SSH_KEY_NAME="rhys-key-public"

readonly user_data=$(base64 $USER_DATA_SCRIPT)

readonly VPC_CIDR='10.0.0.0/22'
readonly PUB_SUB_CIDR='10.0.0.0/24'
readonly PRI_SUB_CIDR='10.0.2.0/24'

: " readonly LINUX2_AMI=$(
  aws ec2 describe-images \
    --owners amazon \
    --filters 'Name=name,Values=amzn2-ami-hvm-2.0.????????.?-x86_64-gp2' 'Name=state,Values=available' \
    --query 'reverse(sort_by(Images, &CreationDate))[:1].ImageId' \
    --output text
) "
readonly LINUX2_AMI='ami-008f4281d2c5de558'

echo "This is the current AMI: ${LINUX2_AMI}"

# validate the template
#aws cloudformation validate-template --template-body "file://${TEMPLATE_FILE}"

# lint
#podman run --rm -v .:/data -it docker.io/aztek/cfn-lint:latest cfn-lint /data/templates/template.yml

# deploys server
aws cloudformation deploy \
  --template-file "${TEMPLATE_FILE}" \
  --capabilities CAPABILITY_IAM \
  --no-fail-on-empty-changeset \
  --stack-name "${STACK_NAME}" \
  --region "${AWS_DEFAULT_REGION}" \
  --tags "Project=Lab16" "Environment=Dev" "StudentName=${STUDENT_NAME}" \
  --parameter-overrides \
      Linux2Ami="${LINUX2_AMI}" \
      UserDataScript="${user_data}" \
      StudentName="${STUDENT_NAME}" \
      VpcCidr="${VPC_CIDR}" \
      PubSubnetCidr="${PUB_SUB_CIDR}" \
      PriSubnetCidr="${PRI_SUB_CIDR}" \
      KeyName="${SSH_KEY_NAME}"
