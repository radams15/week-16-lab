export AWS_REGION=eu-west-2

readonly LINUX2_AMI=$(
  aws ec2 describe-images \
    --owners amazon \
    --filters 'Name=name,Values=amzn2-ami-hvm-2.0.????????.?-x86_64-gp2' 'Name=state,Values=available' \
    --query 'reverse(sort_by(Images, &CreationDate))[:1].ImageId' \
    --output text
)

echo "This is the current Linux 2 AMI: ${LINUX2_AMI}"

UserDataScript=boot.sh
# deploys server
aws cloudformation deploy \
  --template-file "templates/server.yml" \
  --capabilities CAPABILITY_IAM \
  --no-fail-on-empty-changeset \
  --stack-name rhys-adams-vpc-1 \
  --region "${AWS_DEFAULT_REGION}" \
  --parameter-overrides \
      Linux2Ami="${LINUX2_AMI}" \
      UserDataScript="${UserDataScript}" 

