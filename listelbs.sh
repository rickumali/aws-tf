aws elb describe-load-balancers \
    --query 'LoadBalancerDescriptions[*].{Name:LoadBalancerName,ID:CanonicalHostedZoneNameID,DNS:CanonicalHostedZoneName}' \
    --output table
