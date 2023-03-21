@description('Location for all resources.')
param location string = resourceGroup().location

param workflowName string = 'register-device-workflow'
param integrationAccountId string
param serviceBusConnection string
param serviceBusQueueName string
param functionAppName string

resource workflow 'Microsoft.Logic/workflows@2019-05-01' = {
  name: workflowName
  location: location
  tags: {
    project: 'vnext-device'
  }
  properties: {
    state: 'Enabled'
    integrationAccount: {
      id: integrationAccountId
    }
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {
          }
          type: 'Object'
        }
      }
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
          inputs: {
            schema: {
              properties: {
                correlationid: {
                  type: 'string'
                }
                devices: {
                  items: {
                    properties: {
                      Name: {
                        type: 'string'
                      }
                      id: {
                        type: 'string'
                      }
                      location: {
                        type: 'string'
                      }
                      type: {
                        type: 'string'
                      }
                    }
                    required: [
                      'id'
                      'Name'
                      'location'
                      'type'
                    ]
                    type: 'object'
                  }
                  type: 'array'
                }
              }
              type: 'object'
            }
          }
        }
      }
      actions: {
        Compose: {
          runAfter: {
            'When_a_message_is_received_in_a_queue_(auto-complete)': [
              'Succeeded'
            ]
          }
          type: 'Compose'
          inputs: '@decodeBase64(body(\'When_a_message_is_received_in_a_queue_(auto-complete)\')?[\'ContentData\'])'
        }
        Execute_JavaScript_Code: {
          runAfter: {
            Compose: [
              'Succeeded'
            ]
          }
          type: 'JavaScriptCode'
          inputs: {
            code: 'let output = workflowContext.actions.Compose.outputs;\r\nlet payload = JSON.parse(output)\r\n\r\nlet deviceIds = payload.devices.map(item => item.id);\r\n\r\nreturn { deviceIds };'
          }
        }
        Execute_JavaScript_Code_2: {
          runAfter: {
            HTTP: [
              'Succeeded'
            ]
          }
          type: 'JavaScriptCode'
          inputs: {
            code: 'const outputAssets = workflowContext.actions.HTTP.outputs.body;\r\nconst output = workflowContext.actions.Compose.outputs;\r\nconst devices = JSON.parse(output).devices\r\nconst devicesAssetsId = outputAssets.devices\r\n\r\nconst result = devices.map(item => ({\r\n    deviceId: item.id,\r\n    location: item.id,\r\n    name: item.name,\r\n    type: item.type,\r\n    assetId: devicesAssetsId.find(d => d.deviceId === item.id).assetId\r\n}))\r\n\r\nreturn { devices: result };'
          }
        }
        HTTP: {
          runAfter: {
            Execute_JavaScript_Code: [
              'Succeeded'
            ]
          }
          type: 'Http'
          inputs: {
            body: '@body(\'Execute_JavaScript_Code\')'
            headers: {
              'x-functions-key': 'DRefJc8eEDyJzS19qYAKopSyWW8ijoJe8zcFhH5J1lhFtChC56ZOKQ=='
            }
            method: 'POST'
            uri: 'http://tech-assessment.vnext.com.au/api/devices/assetId/'
          }
        }
        HTTP_2: {
          runAfter: {
            Execute_JavaScript_Code_2: [
              'Succeeded'
            ]
          }
          type: 'Http'
          inputs: {
            body: '@body(\'Execute_JavaScript_Code_2\')'
            method: 'POST'
            uri: 'https://${functionAppName}.azurewebsites.net/api/device'
          }
        }
        Send_message: {
          runAfter: {
          }
          type: 'ApiConnection'
          inputs: {
            body: {
              ContentData: '@{base64(triggerBody())}'
              ContentType: 'application/json'
              SessionId: '@triggerBody()?[\'correlationid\']'
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'servicebus\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/@{encodeURIComponent(encodeURIComponent(\'${serviceBusQueueName}\'))}/messages'
          }
        }
        'When_a_message_is_received_in_a_queue_(auto-complete)': {
          runAfter: {
            Send_message: [
              'Succeeded'
            ]
          }
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'servicebus\'][\'connectionId\']'
              }
            }
            method: 'get'
            path: '/@{encodeURIComponent(encodeURIComponent(\'${serviceBusQueueName}\'))}/messages/head'
            queries: {
              queueType: 'Main'
            }
          }
        }
      }
      outputs: {
      }
    }
    parameters: {
      '$connections': {
        value: {
          servicebus: {
            connectionId: serviceBusConnection
            connectionName: 'servicebus-1'
            id: '/subscriptions/2ba97194-b813-454e-bc25-42230db87847/providers/Microsoft.Web/locations/australiaeast/managedApis/servicebus'
          }
        }
      }
    }
  }
}
