import json
import boto3
s3_client=boto3.client('s3')

def lambda_handler(event, context):
    #specify source bucket
    source_bucket_name=event['Records'][0]['s3']['bucket']['name']
    print(source_bucket_name)
    #get object that has been uploaded
    file_name=event['Records'][0]['s3']['object']['key']
    print(file_name)
    #specify destination bucket
    destination_bucket_name='785931089885-processed-bucket'
    #specify from where file needs to be copied
    copy_object={'Bucket':source_bucket_name,'Key':file_name}
    #write copy statement 
    s3_client.copy_object(CopySource=copy_object,Bucket=destination_bucket_name,Key=file_name)

    return {
        'statusCode': 3000,
        'body': json.dumps('File has been Successfully Copied')
    }