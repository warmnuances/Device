# get the first subsription id
subscriptionId=$(az account show | jq -r ."id")

az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${subscriptionId}" --sdk-auth