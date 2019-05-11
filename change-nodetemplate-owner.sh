#!/bin/bash
newowner=''
clusterid=''
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
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
if [ -z "$clusterid" ] || [ -z "$newowner" ];
then
        echo "Usage: change-nodetemplate-owner.sh -c CLUSTER-ID -n NEW-OWNER-ID"
        exit 1
fi
echo -e "${green}Cluster: $clusterid${reset}"
echo -e "${green}New Owner: $newowner${reset}"
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
if ! hash sed 2>/dev/null
then
        echo '!!!sed was not found!!!'
        exit 1
fi
if [ ! -f ~/.kube/config ] && [ -z "$KUBECONFIG" ];
then
	echo "${red}~/.kube/config does not exist and \$KUBECONFIG is not set!${reset} "
	exit 1
fi
echo 
kubectl get node
echo
for nodepoolid in $(kubectl -n $clusterid get nodepool --no-headers -o=custom-columns=NAME:.metadata.name)
do
        nodetemplateid=$(kubectl -n $clusterid get nodepool $nodepoolid -o json | jq -r .spec.nodeTemplateName | cut -d : -f 2)
        oldowner=$(kubectl -n $clusterid get nodepool $nodepoolid -o json | jq -r .spec.nodeTemplateName | cut -d : -f 1)
        echo -e "${red}creating new nodetemplate under $newowner's namespace${reset}"
        kubectl -n $oldowner get nodetemplate $nodetemplateid -o yaml | sed 's/'$oldowner'/'$newowner'/g' | kubectl apply --namespace=$newowner -f -
        echo -e "${red}patching $nodepoolid old owner: $oldowner new owner: $newowner${reset}"
        kubectl -n $clusterid patch nodepool $nodepoolid -p '{"spec":{"nodeTemplateName": "'$newowner:$nodetemplateid'"}}' --type=merge
done
echo
echo
echo -e "${green}We're all done!  If see you kubectl complaining about duplicate nodetemplates, this is safe to ignore.${reset}"
