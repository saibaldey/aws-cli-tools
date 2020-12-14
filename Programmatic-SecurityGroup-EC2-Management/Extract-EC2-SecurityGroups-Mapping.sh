#!/bin/bash

## This tool requires 2 inputs
#  INSTANCE_LIST : Mandatory : File having details about the instances for which we want to extract the Security Groups attached
#  PROFILE       : Optional  : AWS profile, which has been configured while setting up the AWS keys

# Input Arguments & local variables
INSTANCE_LIST=$1
PROFILE=$2
OUTPUT="./SG-details-of-instnaces-from-${INSTANCE_LIST}.log"

## Formatting the log file
echo "instance-name:Security Groups" >${OUTPUT}

sed 1d ${INSTANCE_LIST} | while IFS= read -r line
do
  INSTANCE_NAME=`echo $line | awk '{print $1}'`

  ##extracting the instance id
  INSTANCE_ID=`aws ec2 describe-instances --profile ${PROFILE} --region us-east-2 --filters "Name=tag:Name,Values=${INSTANCE_NAME}" --output text --query 'Reservations[*].Instances[*].[InstanceId]'`

  # Extracting SG of the instance
  SG_LIST=`aws ec2 describe-instances --profile ${PROFILE} --region us-east-2 --filters "Name=tag:Name,Values=${INSTANCE_NAME}" --output text --query 'Reservations[*].Instances[*].SecurityGroups[*]' | awk 'BEGIN { ORS=" " }; {print $1}'`

  ## Generating the output in a format so, that can be used while attaching the SGs once again programmatically
  echo ${INSTANCE_NAME}:${SG_LIST} >>${OUTPUT}
done 
