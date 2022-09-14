# Create s3 bucket then push the code to this
declare region="us-east-1"
declare bucket="my-055771427366-bucket"

if [[ $(aws s3 ls | grep $bucket) != "" ]]; then
  echo "s3 bucket existed!"
else
  aws s3 mb --bucket $bucket
fi

# Copy index.html to bucket
aws s3 cp index.html s3://$bucket
#for f in *.yml; do aws s3 cp $f s3://$bucket; done
#for f in *.json; do aws s3 cp $f s3://$bucket; done

# Create vpc
./create.sh CreateVPC network.yml network-parameters.json $region
# Wait for stack CreateVPC complete
aws cloudformation wait stack-create-complete --stack-name CreateVPC --region $region

#create server
./create.sh CreateSV servers.yml server-parameters.json $region
# get access URL
# Wait for stack CreateSV complete
aws cloudformation wait stack-create-complete --stack-name CreateSV --region $region
echo "Please click on below url to access the webpage"
aws cloudformation describe-stacks --stack-name CreateSV --region $region --query "Stacks[0].Outputs[?OutputKey=='WALB'].OutputValue" --output text
