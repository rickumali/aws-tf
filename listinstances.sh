aws ec2 describe-instances \
    --filter Name=instance-state-name,Values=running \
    --query 'Reservations[*].Instances[*].{Instance:InstanceId,IPAddress:PublicIpAddress,DNS:PublicDnsName}' \
    --output table
