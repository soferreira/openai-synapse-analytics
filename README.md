# How to leverage Azure OpenAI in Azure Synapse Analytics

In this sample we will use Azure OpenAI service from a Synapse Analytics workspace using the [SynapseML](https://microsoft.github.io/SynapseML/docs/about/) library.

## Use case

Classify a review as Positive, Neutral or Negative. 

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/dotnet/azure/install-azure-cli/)
- [Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install/)

> Note: Using PowerBI is an optional way to visulize data.

## Setup and deployment

1. Create a resource group in which the resources would be created.

2. Clone or fork this repository.

3. Edit ```bicep/param.json``` file and provide your values.

4. Open a command line, go to  'openai-synapse-analytics/bicep' and run ```az deployment group create --resource-group <your rg name> --template-file main.bicep --parameters @param.json```.

5. Open the newly created Synapse workspace.

6. Point the Synapse workspace to the cloned/forked repository as shown in this [article](https://docs.microsoft.com/en-us/azure/synapse-analytics/cicd/source-control).
