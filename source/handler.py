def lambda_handler(event, context):
    """
    Main Lambda handler function
    """
    print(f"Processing event: {event}")
    
    # Your business logic here
    
    return {
        'statusCode': 200,
        'body': 'Success!'
    }
