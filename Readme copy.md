// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0


# Rightsize data collection
## Made By OPTICS
This solution will collect rightsizing recommendations from AWS Cost Explorer in your management account and upload them to an Amazon S3 bucket. You can use the saved Athena query as a view to query these results and track your recommendations. Using the organization meta data collector you can attach information such as account name, email and tags from your organization to this data. This should be deployed in a member account which you would like to store the data in. 

## Pre-Requisite

1. Create an IAM role in the management account (where your rightsizing data is). When asked to Select type of trusted entity, choose 'Another AWS Account' and provide the 12 digit account ID of the account you will be deploying the solution into. You can see this in the trusted relationship tab once created. The recommended policy to attach to this role can be found in the files/mgmt_account_policy.json file. Make note of Role ARN and this will be used for the *RoleARN* parameter.
2. Into an existing S3 Bucket, upload the following files. These files need to sit in a folder called *cloudformation*. This S3 Bucket will be referred to as *CodeBucket* in the CloudFormation template parameters and further documentation
```aws s3 cp organization_rightsizing_lambda.yaml s3://<CodeBucket>/cloudformation/organization_rightsizing_lambda.yaml```
```aws s3 cp org.yaml s3://<CodeBucket>/cloudformation/org.yaml```

*  If you plan to do deploy using the cli update the parameters file. If not got to CloudFormation in the AWS console:
CrawlerName:
    Type: String
    Default: crawl-rightsizing-recommendations
    Description: Name of the AWS crawler to be created
    AllowedPattern: ^.*[^0-9]$
    ConstraintDescription: Must end with non-numeric character.
  DestinationBucket:
    Type: String
    Description: Name of the S3 Bucket that exists or needs to be created to hold rightsizing information
    AllowedPattern: (?=^.{3,63}$)(?!^(\d+\.)+\d+$)(^(([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])\.)*([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])$)
  DestinationPrefix:
    Type: String
    Description: Name of the folder/prefix for rightsizing information to be stored in
    Default: rightsizing
  RoleARN:
    Type: String
    Description: ARN of the IAM role deployed in the management accounts which can retrieve AWS Cost Explorer rightsizing information.
  Tags:
    Type: String
    Description: List of tags from your organization you would like to include separated by a comma.
  CodeBucket:
    Type: String
    Description:  Name of the S3 Bucket that exists and holds the code for the athena emailer function
  Region:
    Type: String
    Description: Region of your Code Bucket, the format needs to be eu-west-1 etc


## Deployment
You can deploy through the CLI using the below command or through the [console](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/GettingStarted.html)
``` aws cloudformation create-stack --stack-name rightsizesharesolution --template-body file://main.yaml --capabilities CAPABILITY_NAMED_IAM --parameters file://parameter.json```

### Follow up

Create athena view using the saved query and clicking *Create*. 

Now that you have your rightsizing data and your organization metadata you can join the two sets of data using the join_org_rightsize.sql query. 
In AWS Athena run this query against the view you created above and you should see all your rightsize data connected to the account it comes from.
Using the tags brought in from your AWS organization you can then have a deeper understanding of where to start when reviewing the data or if there any trends such as underutilised instances are in your Dev accounts. 
