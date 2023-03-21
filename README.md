


### Results



### Infrastructure Deployed
<img alt="Bicep Visualisation" src="assets/bicep.png"/>

### Prerequisites
Resources such as resource group have to be deployed in the subscription scope

```bash
az deployment group create \
  --name test-deployment \
  --resource-group rg-vnext-device-prod \
  --template-file infrastructure/main.bicep 
```