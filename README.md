# How to leverage Azure OpenAI in Azure Synapse Analytics

In this tutorial we will leverage Azure OpenAI service from a Synapse Analytics workspace using the [SynapseML](https://microsoft.github.io/SynapseML/docs/about/) library.

The [OpenAICompletion](https://mmlspark.blob.core.windows.net/docs/0.10.0/pyspark/synapse.ml.cognitive.html#module-synapse.ml.cognitive.OpenAICompletion) module offers numerous possibilities for its application, such as data enrichment and implementing data quality changes that may be challenging to achieve with conventional coding techniques. For example, suppose your data has been collected in an inconsistent or non-standardized manner, resulting in poor data quality. In that case, you can use OpenAICompletion to standardize and enrich your data.

## Prerequisites

- Azure Synapse Analytics Workspace
- Azure OpenAI service
- Storage account
- Azure Key Vault

## Setup

1. Clone or fork this repository.
1. Upload the csv sample data into your storage account. The sample data can be found on this repo under the sample-data folder.
1. Open your Synapse workspace.
1. Open the Data tab and connect your workspace with the storage account. You should be abe to see the csv files listed.
1. Point your Synapse Analytics workspace to the cloned/forked repository as shown in this [article](https://docs.microsoft.com/en-us/azure/synapse-analytics/cicd/source-control).
1. Go to Develop > Notebooks and open completions notebook.

## Use Case - Get sentiment from review

Let's say you're working on a project where you need to classify customer reviews of a product as positive, neutral or negative, which can help businesses make more informed decisions about their products and marketing strategies. You have a dataset of customer reviews in different languages and without rating.

In the first cell we will load the csv file into a dataframe.

```python
df = spark.read.load('abfss://<storage_account_name>@<container_name>.dfs.core.windows.net/reviews.csv', format='csv', header=True)
```

![load_df](images/load_df.png)

In the next cell we will define the [OpenAICompletion](https://mmlspark.blob.core.windows.net/docs/0.10.0/pyspark/synapse.ml.cognitive.html#module-synapse.ml.cognitive.OpenAICompletion) API call and add a new column to the dataframe with the corresponding prompt for each row.

```python
from pyspark.sql.functions import *
from synapse.ml.cognitive import OpenAICompletion
from synapse.ml.core.platform import find_secret

openai_service = "<your_openai_service_name>"
openai_deployment = "<your_openai_deployment_name>"

# Get OpenAI key
key = find_secret("<your_openai_secret_name>", "<your_keyvault_service_name>")

# API call definition
completion = (
    OpenAICompletion()
        .setSubscriptionKey(key)
        .setDeploymentName(openai_deployment)
        .setUrl("https://<your_openai_service_name>.openai.azure.com/")
        .setPromptCol("prompt")
        .setErrorCol("error")
        .setOutputCol("output")
)

# Define prompt to get review's sentiment
df = df.withColumn("prompt", 
            concat(lit("Decide whether a review's sentiment is positive, neutral, or negative. Review: ")
            , col("review"), lit(" Sentiment:")))

```

After making the call, the output will be presented in a JSON format, containing the result as well as several other details in the designated column. Subsequently, we will create a new column named response specifically for the sentiment value.

```python
from pyspark.sql.functions import *

df_completion = completion.transform(df).withColumn("response", col("output.choices.text").getItem(0))
```

```json
{
    "model":"text-davinci-003",
    "choices":[{"text":" Positive","index":0,"finish_reason":"stop"}],
    "object":"text_completion",
    "id":"cmpl-6mKImBBsdcilzBJVttNXixeBrKmGD",
    "created":"1676975804"
}
```

![output_sentiment](images/output_sentiment.png)

## Use Case - Get address information from unstandardized data

Suppose that due to the lack of standardized data collection practices, your data contains various formats for addresses, making it challenging to perform geolocation-based analysis. To address this issue, you can leverage OpenAICompletion to standardize the address format across the dataframe.

```python
from synapse.ml.cognitive import OpenAICompletion
from synapse.ml.core.platform import find_secret

openai_service = "<your_openai_service_name>"
openai_deployment = "<your_openai_deployment_name>"

key = find_secret("<your_openai_secret_name>", "<your_keyvault_service_name>")

# API call definition
completion = (
    OpenAICompletion()
        .setSubscriptionKey(key)
        .setDeploymentName(openai_deployment)
        .setUrl("https://<your_openai_service_name>.openai.azure.com/")
        .setPromptCol("prompt")
        .setErrorCol("error")
        .setOutputCol("output")
)
# Define prompt to get country code from the address
df = df.withColumn("prompt", 
            concat(lit("Provide Country ISO standard two-letter code for the address: ")
            , col("Address"), lit(" ISO standard two-letter code:")))

# Call API 
df_completion = completion.transform(df).withColumn("Country", col("output.choices.text").getItem(0))
display(df_completion)

```

Similarly, you can create additional prompts to retrieve street name, postal code or to generate new columns, such as longitude and latitude, based on the standardized address format.
