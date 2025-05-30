import json
import boto3
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource('dynamodb')
TABLE_NAME = 'livechat-Dynamo-Message'

def lambda_handler(event, context):
    try:
        # Obter parâmetros da query string, se existirem
        query_parameters = event.get('queryStringParameters', {}) or {}
        
        # Inicializar parâmetros para scan/query
        limit = int(query_parameters.get('limit', 50))  # Padrão: 50 mensagens
        user_filter = query_parameters.get('user')
        
        table = dynamodb.Table(TABLE_NAME)
        
        # Se um usuário específico foi solicitado, use query com índice secundário
        # Caso contrário, faça um scan da tabela
        if user_filter:
            # Nota: Isso assume que você tem um índice secundário global em 'user'
            # Se não tiver, você precisará criar ou usar scan com filtro
            response = table.query(
                IndexName='user-index',
                KeyConditionExpression=Key('user').eq(user_filter),
                Limit=limit,
                ScanIndexForward=False  # Para obter as mensagens mais recentes primeiro
            )
        else:
            # Scan simples para obter todas as mensagens
            response = table.scan(
                Limit=limit
            )
        
        # Extrair itens da resposta
        items = response.get('Items', [])
        messages = [
            {
                'user': item.get('user', ''),
                'message': item.get('message', '\n')
            }
            for item in items
        ]        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'messages': messages,
                'count': len(messages)
            }, ensure_ascii=False)  # <- Isso mantém os acentos!
        }    
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'error': str(e)})
        }
