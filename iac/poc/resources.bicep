param appName string = 'poc'

@allowed([
  'dev'
  'test'
  'prod'
])
param env string = 'dev'

@secure()
param vmAdminUsername string

@secure()
param vmAdminPassword string = newGuid()

var addressPrefix = '10.0.0.0/16'

module vnet 'br/public:avm/res/network/virtual-network:0.1.7' = {
  name: '${uniqueString(deployment().name)}-vnet'
  params: {
    addressPrefixes: [
      cidrSubnet(addressPrefix, 16, 0)
    ]
    name: 'vnet-${env}-${appName}-001'
    subnets: [
      {
        addressPrefix: cidrSubnet(addressPrefix, 24, 0)
        name: 'snet-${env}-${appName}-001'
      }
    ]
  }
}

module automationAccount 'br/public:avm/res/automation/automation-account:0.5.0' = {
  name: '${uniqueString(deployment().name)}-aa'
  params: {
    name: 'aa-${env}-${appName}-001'
  }
}

module vm 'br/public:avm/res/compute/virtual-machine:0.5.1' = {
  name: '${uniqueString(deployment().name)}-vm'
  params: {
    name: 'vm-${env}-${appName}-001'
    osType: 'Windows'
    vmSize: 'Standard_B2s'
    zone: 0
    adminUsername: vmAdminUsername
    adminPassword: vmAdminPassword
    imageReference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2022-datacenter'
      version: 'latest'
    }
    nicConfigurations: [
      {
        name: 'nic-vm-${env}-${appName}-001'
        deleteOption: 'Delete'
        ipConfigurations: [
          {
            name: 'ipconfig01'
            subnetResourceId: vnet.outputs.subnetResourceIds[0]
          }
        ]
        enableAcceleratedNetworking: false
      }
    ]
    osDisk: {
      diskSizeGB: 128
      managedDisk: {
        storageAccountType: 'StandardSSD_LRS'
      }
    }
    encryptionAtHost: false
    licenseType: 'Windows_Server'
  }
}
