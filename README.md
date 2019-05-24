# Rancher 2.x nodetemplate tools
## Change nodetemplate owner
This script will change your nodetemplate owner in Rancher 2.x.  You can run this script as a Docker image or directly as a bash script.  You'll need the cluster ID and the user ID you want to change the ownership to.
1. To obtain the cluster ID in the Rancher user interface, Navigate to Global> "Your Cluster Name"> then grab the cluster ID from your address bar.  I have listed an example of the URL and a cluster ID derrived from the URL below.
   * Example URL: `https://<RANCHER URL>/c/c-48x9z/monitoring`
   * Derrived cluster ID from above URL: **c-48x9z**
2. Now we need the user ID of the user to become the new nodetemplate owner, navigate to Global> Users> to find the ID.
3. To run the script using a docker image, make sure your $KUBECONFIG is set to the full path of your Rancher local cluster kube config then run the following command.

    ```bash
    docker run -v $KUBECONFIG:/root/.kube/config patrick0057/change-nodetemplate-owner -c <cluster-id> -n <user-id>
    ```
4. To run the script directly, just download change-nodetemplate-owner.sh, make sure your $KUBECONFIG or ~/.kube/config is pointing to the correct Rancher local cluster then run the following command:

    ```bash
    ./change-nodetemplate-owner.sh -c <cluster-id> -n <user-id>
    ```
## Assign a nodetemplate to a cluster's nodepool.
Assign a nodetemplate to a cluster's nodepool.  This is useful for situations where the original owner of a cluster has been deleted which also deletes their nodetemplates.  To use this task successfully it is recommended that you create a new nodetemplate in the UI before 
using it.  Make sure the node template matches the original ones as closely as possible.

Run script with docker image:

    ```bash
    docker run -v $KUBECONFIG:/root/.kube/config patrick0057/change-nodetemplate-owner -t changenodetemplate -c <cluster-id>
    ```
Run script from bash command line:

    ```bash
    ./change-nodetemplate-owner.sh -t changenodetemplate -c <cluster-id>
    ```
