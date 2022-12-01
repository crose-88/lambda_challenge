import pytest
import boto3
import botocore.exceptions

upload_bucket_name = '785931089885-upload-bucket'
processed_bucket_name = '785931089885-processed-bucket'

upload_role_arn = 'arn:aws:iam::785931089885:role/uploader'
download_role_arn = 'arn:aws:iam::785931089885:role/downloader'

def assumed_role_session(role_arn):
	sts_client = boto3.client('sts')
	assumed_role_object = sts_client.assume_role(
	    RoleArn=role_arn,
	    RoleSessionName='session12345'
	)
	print(assumed_role_object)
	credentials = assumed_role_object['Credentials']
	session = boto3.Session(
	    aws_access_key_id=credentials['AccessKeyId'],
	    aws_secret_access_key=credentials['SecretAccessKey'],
	    aws_session_token=credentials['SessionToken']
	)
	return session


def get_bucket_object(session, bucket_name, object_name):
	client = session.resource('s3')
	client.Bucket(bucket_name).put_object(Key=object_name, Body=valid_data)
	return client.Object(bucket_name, object_name)	

def test_valid_upload():
	"""
	Test we can upload a png into upload bucket
	"""
	session = assumed_role_session(upload_role_arn)
	s3_client = session.resource('s3')
	valid_data = open('test.png', 'rb')
	s3_client.Bucket(upload_bucket_name).put_object(Key='test.png', Body=valid_data)
	s3_obj = s3_client.Object(upload_bucket_name, 'test.png')
	s3_obj.delete

def test_invalid_upload():
	"""
	Test we cannot upload a jpg into upload bucket
	"""
	session = assumed_role_session(upload_role_arn)
	s3_client = session.resource('s3')
	valid_data = open('test.png', 'rb')
	with pytest.raises(botocore.exceptions.ClientError):
		s3_client.Bucket(upload_bucket_name).put_object(Key='test.jpg', Body=valid_data)

def test_no_upload_from_downloader():
	"""
	Test we cannot upload a png into upload bucket with download role
	"""
	session = assumed_role_session(download_role_arn)
	s3_client = session.resource('s3')
	valid_data = open('test.png', 'rb')
	with pytest.raises(botocore.exceptions.ClientError):
		s3_client.Bucket(upload_bucket_name).put_object(Key='test.png', Body=valid_data)

# def test_no_upload_to_processed_bucket_upload_role():
# 	"""
# 	Test we cannot upload anything to processed bucket from upload role
# 	"""
# 	session = assumed_role_session(upload_role_arn)
# 	s3_client = session.resource('s3')
# 	valid_data = open('test.png', 'rb')
# 	with pytest.raises(botocore.exceptions.ClientError):
# 		s3_client.Bucket(processed_bucket_name).put_object(Key='test1.png', Body=valid_data)

# def test_no_upload_to_processed_bucket_download_role():
# 	"""
# 	Test we cannot upload anything to processed bucket from upload role
# 	"""
# 	session = assumed_role_session(download_role_arn)
# 	s3_client = session.resource('s3')
# 	valid_data = open('test.png', 'rb')
# 	with pytest.raises(botocore.exceptions.ClientError):
# 		s3_client.Bucket(processed_bucket_name).put_object(Key='test2.png', Body=valid_data)


def test_image_copied_correctly():
	"""
	test uploaded image is copied correctly
	"""
	upload_session = assumed_role_session(upload_role_arn)
	download_session = assumed_role_session(download_role_arn)
	s3_client = upload_session.resource('s3')
	valid_data = open('test.png', 'rb')
	s3_client.Bucket(upload_bucket_name).put_object(Key='test.png', Body=valid_data)
	s3_upload_object = get_bucket_object(upload_session, upload_bucket_name, 'test.png')
	s3_processed_object = get_bucket_object(download_processed_bucket_name, 'test.png')
	assert(s3_upload_object.size == s3_processed_object.size)
