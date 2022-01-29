#!/bin/sh
set -e

# This url is taken from the AWS Console on the EKS management screen for any
# given cluster
cluster_oidc_url=$(echo ${CLUSTER_OIDC_URL} | cut -c 9-)

# We have to specify a port here for the cli argument we will give to openssl
with_port=$(echo $cluster_oidc_url | sed s/\.com.*/.com:443/)

# Gets the full cert information from our OIDC url
full=$(openssl s_client -servername $cluster_oidc_url/keys -showcerts -connect $with_port < /dev/null 2>/dev/null)

# Parse out the bottom most cert definition which is the root CA in the certificate chain
root=$(echo "$full" | \
  # Keep only the begin and end lines and everything in between
  sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | \
  # Reverse the order of the lines
  tac | \
  # Delete everything after the first begin line (which is the start of the last cert)
  sed '/-----BEGIN CERTIFICATE-----/q' | \
  # Un-reverse
  tac)

# Print the fingerprint, and parse out verbose information and formatting
echo "Fingerprint:"
echo "$root" | openssl x509 -in /dev/stdin -fingerprint -noout | tail -n1 | sed 's|:||g' | cut -c 18-

echo
echo "Expiration date:"
echo "$root" | openssl x509 -enddate -noout -in /dev/stdin
