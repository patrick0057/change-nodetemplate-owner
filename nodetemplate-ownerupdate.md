# Rancher nodetemplate owner change
This guide will show you how to change your nodetemplate owner for situations where the original user is no longer with the company.  This guide will only work if the original user has not already been deleted.  If the original user has been deleted it is possible that your nodetemplate may already be deleted.
1. We need gather some information before we get started for future commands, starting with the ID of the cluster in question.  Make sure to save all information we are identifying in a text file somewhere for later use.  In the Rancher user interface, select your cluster then grab the cluster ID from your address bar.  I have listed an example of the URL and cluster ID below.
   * Example URL: `https://<RANCHER URL>/c/c-48x9z/monitoring`
   * Derrived cluster ID from above URL: **c-48x9z**
2. Open a terminal with kubectl config (~/.kube/config) pointing to your local Rancher cluster.

    ```bash
    root@86993adde452:~# export clusterid=c-48x9z
    ```
3. Now we need the user ID of the original nodetemplate owner and the user ID of the future nodetemplate owner.  Navigate to Global> Users> to find the IDs.
   * In my tutorial **user-xfmrm** will be the original nodetemplate owner and **u-7z9jc** will be the new nodetemplate owner.
        ```bash
        root@86993adde452:~# export originalowner=user-xfmrm
        root@86993adde452:~# export newowner=u-7z9jc
        root@86993adde452:~#
        ```
4. We need to identify the nodepool ID associated with this cluster using the following command: 

    ```bash
    root@86993adde452:~# kubectl -n $clusterid get nodepool
    NAME       AGE
    np-pnxwz   1h
    root@86993adde452:~# export nodepoolid=np-pnxwz
    root@86993adde452:~#
    ```
5. Using the nodepool ID and cluster ID, use the following command to identify the nodetemplate ID: 
  
    ```bash
    root@86993adde452:~# kubectl -n $clusterid get nodepool $nodepoolid -o yaml | grep nodeTemplateName| cut -d : -f 3
    nt-9bn8d
    root@86993adde452:~# export nodetemplateid=nt-9bn8d
    root@86993adde452:~# 
    ```
6. Patch the nodepool in question using the following command:
    ```bash
    root@86993adde452:~# kubectl -n $clusterid patch nodepool $nodepoolid -p '{"spec":{"nodeTemplateName": "'$newowner:$nodetemplateid'"}}' --type=merge
    nodepool.management.cattle.io/np-pnxwz patched
    root@86993adde452:~#
    ```
7. Dump the nodetemplate in question, patch it then reapply it.

    ```bash
    kubectl -n $originalowner get nodetemplate $nodetemplateid -o yaml > ~/$nodetemplateid.yaml
    sed -i 's/'$originalowner'/'$newowner'/g' ~/$nodetemplateid.yaml
    kubectl apply --namespace=$newowner -f ~/$nodetemplateid.yaml
    ```


