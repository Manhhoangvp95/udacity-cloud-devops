# Create s3 bucket then push the code to this
declare region="us-east-1"
declare bucket="my-055771427366-bucket"
echo "Start create bucket"
if [[ $(aws s3 ls | grep $bucket) != "" ]]; then
  echo "s3 bucket existed!"
else
  aws s3 mb --bucket $bucket
  echo "Start create bucket complete"
fi
echo "End create bucket"
# Copy index.html to bucket
echo "Start copy file to bucket"
aws s3 cp index.html s3://$bucket
#for f in *.yml; do aws s3 cp $f s3://$bucket; done
#for f in *.json; do aws s3 cp $f s3://$bucket; done
echo "End copy file to bucket"
# Create vpc
echo "Start create stack to create network infra"
./create.sh CreateVPC network.yml network-parameters.json $region
# Wait for stack CreateVPC complete
aws cloudformation wait stack-create-complete --stack-name CreateVPC --region $region
echo "End create stack to create network infra"
#create server
echo "Start create stack to create server infra"
aws cloudformation create-stack --stack-name CreateSV --template-body file://servers.yml  --parameters file://server-parameters.json --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM" --region=$region

# get access URL
# Wait for stack CreateSV complete
aws cloudformation wait stack-create-complete --stack-name CreateSV --region $region
echo "End create stack to create server infra. Workflow end."
echo "Please click on below url to access the webpage"
aws cloudformation describe-stacks --stack-name CreateSV --region $region --query "Stacks[0].Outputs[?OutputKey=='WALB'].OutputValue" --output text
