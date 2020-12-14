#!/bin/bash

## This tool requires 2 inputs
#  SG_Instance_MAP : Mandatory : File having details about the instances along with the desired Security Groups to be attached
#  PROFILE         : Optional  : AWS profile, which has been configured while setting up the AWS keys

## Local variable
SG_Instance_MAP=$1
PROFILE=$2
OUTPUT="./SG-Attachment-to-Instances-as-per-${SG_Instance_MAP}.log"

## Formatting the log file
echo "Attempting to attach SG to the instances as par below details" >${OUTPUT}
echo "instance-name, Instance ID, Security Groups" >>${OUTPUT}

## Skipping the 1st headed line
sed 1d $SG_Instance_MAP | while IFS= read -r line
do

  ## Extracting the Instance Name & corresponding Security Groups 
  INSTANCE_NAME=`echo $line | awk -F":" '{print $1}'`
  SG_LIST=`echo $line | awk -F":" '{print $2}'`

  ##extracting the instance id using the Instance Name
  INSTANCE_ID=`aws ec2 describe-instances --profile ${PROFILE} --region us-east-2 --filters "Name=tag:Name,Values=${INSTANCE_NAME}" --output text --query 'Reservations[*].Instances[*].[InstanceId]'`

  ## Adding an entry into the log file for later checks
  echo INSTANCE_NAME=${INSTANCE_NAME}, INSATNCE_ID=${INSTANCE_ID}, SG_LIST=${SG_LIST} >>${OUTPUT}

  ## Attempting to attach the SGs to the instance
  aws ec2 modify-instance-attribute --profile ${PROFILE} --instance-id ${INSTANCE_ID} --groups ${SG_LIST} >>${OUTPUT}

  ## Empty line for log formatting
  echo "">>${OUTPUT}
done 
