# Rancher nodetemplate owner change
This guide will show you how to change your nodetemplate owner for situations where the original user is no longer with the company.  This guide will only work if the original user has not already been deleted.  If the original user has been deleted it is possible that your nodetemplate may already be deleted.
1. We need gather some information before we get started for future commands, starting with the ID of the cluster in question.  Make sure to save all information we are identifying in a text file somewhere for later use.  In the Rancher user interface, select your cluster then grab the cluster ID from your address bar.  I have listed an example of the URL and cluster ID below.
  * Example URL: https://<RANCHER URL>/c/c-48x9z/monitoring
  * Derrived cluster ID from above URL: **c-48x9z**
2.  Now we need the user ID of the original nodetemplate owner and the user ID of the future nodetemplate owner.  Navigate to Global> Users> to find the IDs.
  * In my tutorial **user-xfmrm** will be the original nodetemplate owner and **u-7z9jc** will be the new nodetemplate owner.
3. Open a terminal with kubectl pointing to your local Rancher cluster.
4. We need to identify the nodepool ID associated with this cluster using the following command: 
   `kubectl get nodepool -n <cluster ID>`
   Example: 
 ```root@86993adde452:~# kubectl -n c-48x9z get nodepool
NAME       AGE
np-pnxwz   1h
 ```
 4. Using the nodepool ID and cluster ID, use the following command to identify the nodetemplate ID: 
 `kubectl -n <cluster ID> get nodepool <nodepool ID> -o yaml | grep nodeTemplateName| cut -d : -f 3`
 ```root@86993adde452:~# kubectl -n c-48x9z get nodepool np-pnxwz -o yaml | grep nodeTemplateName| cut -d : -f 3
nt-9bn8d
 ```

4. Dump the nodetemplate in question using the following command: `kubectl -n <original owner ID> get nodetemplate
