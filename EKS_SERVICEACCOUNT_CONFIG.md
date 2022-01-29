# EKS Service Account Configuration

IAM requires that your OIDC configuration needs a thumbprint configured. If you
enable your ServiceAccount configuration with the AWS Console, the thumbprint
is set automatically for you. In terraform, you need to set it yourself. Below,
we will outline the steps for how to get the thumbprint for the Root CA.

We've set this value to be part of each cluster created with this module
already, but in case this needs to be fetched and updated, we've made a
convenient utility container.

Open your AWS Console and navigate to any given EKS cluster. The root CA used
by them is the same across all regions so it doesn't matter which cluster you
use.

Fetch the OIDC Url that's been provisioned for you and export it as an
environment variable. It should look something like:

`export CLUSTER_OIDC_URL=https://oidc.eks.us-west-2.amazonaws.com/id/01D04C54DBFA7900815661766A575FF1`

Navigate to the `./hack/fingerprint_finder` directory and type `make run`.

A container will be built for you with openssl installed, then will be executed. You should get an output like so:
```
Fingerprint:
9E99A48A9960B14926BB7F3B02E22DA2B0AB7280

Expiration date:
notAfter=Jun 28 17:39:16 2034 GMT
```

This is the fingerprint to put into `eks.tf`.

More information:
* [Tutorial on fetching fingerprint](https://medium.com/@marcincuber/amazon-eks-with-oidc-provider-iam-roles-for-kubernetes-services-accounts-59015d15cb0c)
