targetScope = 'subscription'

param azhopResourceGroup string

@description('Admin user for the Virtual Machines.')
param adminUser string

@description('Home directory mountpoint on the VMs.')
param homedirMountpoint string = '/anfhome'

@description('SSH Public Key for the Virtual Machines.')
@secure()
param adminSshPublicKey string

@description('SSH Private Key for the Virtual Machines.')
@secure()
param adminSshPrivateKey string

@description('The Windows/Active Directory password.')
@secure()
param adminPassword string

@description('Azure region to use')
param location string = deployment().location

@description('Slurm accounting admin user')
param slurmAccountingAdminUser string = 'sqladmin'

@description('Password for the Slurm accounting admin user')
@secure()
param slurmAccountingAdminPassword string

@description('Branch of the azhop repo to pull - Default to main')
param branchName string = 'main'

resource azhopRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: azhopResourceGroup
  location: location
}

module azhopModule './azhop.bicep' = {
  name: 'azhop'
  scope: azhopRg
  params: {
    adminUser: adminUser
    homedirMountpoint: homedirMountpoint
    adminSshPublicKey: adminSshPublicKey
    adminSshPrivateKey: adminSshPrivateKey
    adminPassword: adminPassword
    location: location
    slurmAccountingAdminUser: slurmAccountingAdminUser
    slurmAccountingAdminPassword: slurmAccountingAdminPassword
    branchName: branchName
  }
}

var subscriptionReaderRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(azhopRg.id, subscriptionReaderRoleDefinitionId)
  properties: {
    roleDefinitionId: subscriptionReaderRoleDefinitionId
    principalId: azhopModule.outputs.ccportal_mi_principal_id
    principalType: 'ServicePrincipal'
  }
}
