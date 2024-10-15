param location string  // Set this in parameters to avoid using resourceGroup().location
param appServicePlanName string
param appServiceAppName string
param appServiceAPIAppName string
param appServiceAPIEnvVarENV string
param appServiceAPIEnvVarDBHOST string
param appServiceAPIEnvVarDBNAME string
@secure()
param appServiceAPIEnvVarDBPASS string
param appServiceAPIDBHostDBUSER string
param appServiceAPIDBHostFLASK_APP string
param appServiceAPIDBHostFLASK_DEBUG string
@allowed([
  'nonprod'
  'prod'
])
param environmentType string

var appServicePlanSkuName = (environmentType == 'prod') ? 'B1' : 'B1' // Adjust capacity for production if needed

// App Service Plan Resource
resource appServicePlan 'Microsoft.Web/serverFarms@2022-03-01' = {
  name: appServicePlanName
  location: location  // Directly use the passed location
  sku: {
    name: appServicePlanSkuName
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

// Backend App Service (Python)
resource appServiceAPIApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAPIAppName
  location: location  // Directly use the passed location
  properties: {
    serverFarmId: appServicePlan.id  // Link to App Service Plan
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.11'
      alwaysOn: false
      ftpsState: 'FtpsOnly'
      appSettings: [
        {
          name: 'ENV'
          value: appServiceAPIEnvVarENV
        }
        {
          name: 'DBHOST'
          value: appServiceAPIEnvVarDBHOST
        }
        {
          name: 'DBNAME'
          value: appServiceAPIEnvVarDBNAME
        }
        {
          name: 'DBPASS'
          value: appServiceAPIEnvVarDBPASS
        }
        {
          name: 'DBUSER'
          value: appServiceAPIDBHostDBUSER
        }
        {
          name: 'FLASK_APP'
          value: appServiceAPIDBHostFLASK_APP
        }
        {
          name: 'FLASK_DEBUG'
          value: appServiceAPIDBHostFLASK_DEBUG
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
      ]
    }
  }
}

// Frontend App Service (Node.js)
resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppName
  location: location  // Directly use the passed location
  properties: {
    serverFarmId: appServicePlan.id  // Link to App Service Plan
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'NODE|18-lts'
      alwaysOn: false
      ftpsState: 'FtpsOnly'
      appCommandLine: 'pm2 serve /home/site/wwwroot --spa --no-daemon'
      appSettings: []
    }
  }
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName
