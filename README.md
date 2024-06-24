# eks

An EKS cloudformation manifest and orchestration workflow.

- [Requirements](#requirements)
- [Usage](#usage)
- [License](#license)

## Requirements

A list of notable dependencies, versions, at the time of development. Unless otherwise noted, [GNU core utils](https://en.wikipedia.org/wiki/List_of_GNU_Core_Utilities_commands) are the expected default.  

- aws, aws-cli/2.15.47
```sh
$ aws --version
aws-cli/2.15.47 Python/3.11.8 Darwin/17.7.0 exe/x86_64 prompt/off
```

## Usage

An overview of eks orchestration workflow.

1\. Create a [eksctl configuration](https://eksctl.io/usage/schema/) overlay. 
```sh
$ tee overlays/cache-stack.yaml <<eof 
---
metadata:
  name: cache-stack
  region: us-east-1
managedNodeGroups:
  - name: cache-stack-varnish
    privateNetworking: false
    instanceType: m5.large
    desiredCapacity: 3
    minSize: 1
    maxSize: 3
    labels:
      nodegroup: vache-stack-varnish

eof
```

2\. Generate a decarative configuration "plan". 
```sh
$ AWS_PROFILE=EKSAssumeRole \
  OVERLAYS=overlays/cache-stack.yaml \
  make 
...
Assume Role MFA token code:
```
```sh
$ <dist/plan.yaml head -n5
accessConfig:
  authenticationMode: API_AND_CONFIG_MAP
addonsConfig: {}
apiVersion: eksctl.io/v1alpha5
availabilityZones:
```

3\. Apply configuration "plan".
```sh
$ AWS_PROFILE=EKSAssumeRole make install
: ## install
eksctl create cluster \
        -f dist/plan.yaml \
        --kubeconfig dist/config \
        --write-kubeconfig=true
...
2024-06-24 12:43:56 [ℹ]  building cluster stack "eksctl-cache-stack-cluster"
2024-06-24 12:43:57 [ℹ]  deploying stack "eksctl-cache-stack-cluster"
...
```

## License

[MIT](https://choosealicense.com/licenses/mit/)
