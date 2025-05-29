import json
import uuid
import boto3

dynamodb = boto3.resource('dynamodb')
TABLE_NAME = 'livechat-Dynamo-Message'

def lambda_handler(event, context):
    # Garante que body seja um dicionário
    try:
        if isinstance(event.get('body'), str):
            body = json.loads(event['body'])
        elif isinstance(event.get('body'), dict):
            body = event['body']
        else:
            body = {}
    except Exception:
        return {
            'statusCode': 400,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'message': 'Body inválido'})
        }

    user = body.get('user', 'anonimo')
    message = body.get('message')
    id = str(uuid.uuid4())

    table = dynamodb.Table(TABLE_NAME)
    table.put_item(
        Item={
            'id': id,
            'user': user,
            'message': message
        }
    )
    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps({'message': 'Mensagem salva com sucesso!'})
    }
