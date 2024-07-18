aws ec2 describe-instances \
    --filter Name=instance-state-name,Values=running \
    --query 'Reservations[*].Instances[*].{Instance:InstanceId,"Public IP":PublicIpAddress,DNS:PublicDnsName}' \
    --output table
