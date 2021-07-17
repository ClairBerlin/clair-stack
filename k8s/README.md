# Kubernetes Deployment

The `base` directory contains Kubernetes manifest files to deploy the Clair Berlin stack to a Kubernetes cluster.

## Environment and Configuration Management

We use [Kustomize](https://kustomize.io/) to configure the stack for different environments. An environment's configuration consists of a set of environment variables used to generate a config map called `clair-config-map` and a set of password files used to generate a secret called `clair-secret`. The secret files in `base/secrets` do not contain any real passwords. You will have to create a [Kustomize overlay](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/#bases-and-overlays) to override them.

You can use the following shell script to generate the skeleton of a new environment (set ENV_NAME accordingly):

```shell
ENV_NAME=staging
ENV_DIR=environmemnts/$ENV_NAME
mkdir -p $ENV_DIR
cp -R base/config.env base/secrets $ENV_DIR
```

After that, create `$ENV_DIR/kustomization.yaml` with the following content:

```yaml
resources:
  - ../../base

configMapGenerator:
  - name: clair-config-map
    namespace: clair-berlin
    behavior: replace
    envs:
      - config.env

secretGenerator:
  - name: clair-secret
    namespace: clair-berlin
    behavior: replace
    files:
      - secrets/clairchen-forwarder-access-key.txt
      - secrets/ers-forwarder-access-key.txt
      - secrets/ingestair-secret-key.txt
      - secrets/managair-secret-key.txt
      - secrets/sentry-url.txt
      - secrets/smtp-password.txt
      - secrets/sql-password.txt
```

Finally, edit `$ENV_DIR/config.env` and the files in `$ENV_DIR/secrets` to adapt the evironment's configuration.
## Deployment

To deploy an environment do the following:

1) activate the target cluster's context using
```shell
kubectl config use-context $STAGING_CONTEXT
```
2) apply the kustomized manifest files
```shell
kubectly apply -k $ENV_DIR
```
