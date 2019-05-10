#!/bin/sh
while getopts "h:c:n:" opt; do
  case ${opt} in
    h ) # process option h
     echo "Usage: change-nodetemplate-owner.sh -c CLUSTER-ID -n NEW-OWNER-ID"
     exit 1
      ;;
    c ) # process option c
            clusterid=$OPTARG
      ;;
    n ) # process option n
            newowner=$OPTARG
      ;;
    \? )
      echo "Invalid Option: -$OPTARG" 1>&2
      exit 1
      ;;
  esac
done
#shift $((OPTIND -1))
echo Cluster: $clusterid
echo New Owner: $newowner
echo 
exit 1
if ! hash kubectl 2>/dev/null
then
        echo "!!!kubectl was not found!!!"
        echo "!!!download and install with:"
        echo "curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
        echo "chmod +x ./kubectl"
        echo "mv ./kubectl /bin/kubectl"
        exit 1
fi
if ! hash jq 2>/dev/null
then
        echo '!!!jq was not found!!!'
        echo "!!!download and install with:"
        echo "curl -L -O https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
        echo "chmod +x jq-linux64"
        echo "mv jq-linux64 /bin/jq"
        exit 1
fi

for nodepoolid in $(kubectl -n c-48x9z get nodepool --no-headers -o=custom-columns=NAME:.metadata.name)
do
        nodetemplateid=$(kubectl -n $clusterid get nodepool $nodepoolid -o json | jq -r .spec.nodeTemplateName | cut -d : -f 2)
        oldowner=$(kubectl -n $clusterid get nodepool $nodepoolid -o json | jq -r .spec.nodeTemplateName | cut -d : -f 1)
        echo -e "\e[31mcreating new nodetemplate under $newowner's namespace\e[0m"
        kubectl -n $oldowner get nodetemplate $nodetemplateid -o yaml | sed 's/'$oldowner'/'$newowner'/g' | kubectl apply --namespace=$newowner -f -
        echo -e "\e[31mpatching $nodepoolid old owner: $oldowner new owner: $newowner\e[0m"
        kubectl -n $clusterid patch nodepool $nodepoolid -p '{"spec":{"nodeTemplateName": "'$newowner:$nodetemplateid'"}}' --type=merge
done

echo -e "\e[92mWe're all done!  If you've used this script on a cluster previously, you'll likely see kubectl complain about existing nodetemplates.  This is safe to ignore.\e[0m"
