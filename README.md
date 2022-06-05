# vault-kubernetes

Install vault with kubernetes manifests

First - Create Kubernetes namespace named vault where kubernetes resources will run. Create ServiceAccount and bind it to ClusterRole using ClusterRoleBinding.

To create ServiceAccount run --- kubectl apply -f vaultserviceaccount.yaml -n vault
To create ClusterRoleBinding run --- kubectl apply -f rbac.yaml -n vault

Second - Create PV to hold vault data and PVC for the vault pod to request storage from PV
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml -n vault

Third - Create Configmap where vault configuration data will be stored and secret where we will store our key or keys to later unseal vault
kubectl apply -f configmap.yaml -n vault
kubectl apply -f vault-secret.yaml -n vault

Fourth - Vault exposes its UI at port 8200. We will use service of type NodePort to access this endpoint from outside Kubernetes Cluster. 
kubectl apply -f services.yaml -n vault

Fifth - Create the statefulset 
kubectl apply -f statefulset.yaml

Sixth - At this point kubernetes will be uninitialized so we need to initialize it using the following command:
kubectl exec -n vault vault-0 -- vault operator init -key-shares=1 -key-threshold=1
Here key-threshold is set to one meaning that it will generate only one key for unsealing. You can change this value up to five.

Seventh - After initialization vault is still sealed and every time the vault pod is restarted, it will be sealed and so services won't be able to connect to it. In this case I solved the problem by creating simple script named test-bash.sh which I put in cronjob. It will check every 10 minutes whether the pod is 0/1 or 1/1. If it is 0/1, it means that vault is sealed and it will run this simple command to unseal it:

kubectl exec -n vault vault-"$input0" -- vault operator unseal $VAULT_DECODED_KEY

$VAULT_DECODED_KEY this is the variable holding the vault unseal key decoded.
