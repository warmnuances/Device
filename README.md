```bash
az deployment group create \
  --name test-deployment \
  --resource-group rg-vnext-device-prod \
  --template-file infrastructure/main.bicep 
```