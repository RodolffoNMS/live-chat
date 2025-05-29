import json
import os
import time
import urllib.parse
import requests

def lambda_handler(event, context):
    try:
        # Obter credenciais do evento ou do Secret Manager
        client_id = os.environ.get('client_id')
        client_secret = os.environ.get('client_key')
        
        # Obter parâmetros do evento
        quick_command_slug = 'livechat-censor'
        input_data = event['input_data']
        max_retries = event.get('max_retries', 30)  # Número máximo de tentativas
        retry_interval = event.get('retry_interval', 2)  # Intervalo em segundos
        
        print(f"Iniciando execução com input_data: {input_data}")
        
        # 1. Obter access_token
        access_token = get_access_token(client_id, client_secret)
        print(f"Token obtido com sucesso")
        
        # 2. Executar Quick Command
        execution_id = execute_quick_command(access_token, quick_command_slug, input_data)
        print(f"Quick Command executado. ID: {execution_id}")
        
        # 3. Monitorar status da execução
        result = monitor_execution(access_token, execution_id, max_retries, retry_interval)
        print(f"Monitoramento concluído. Resultado: {json.dumps(result)}")
        
        return {
            "statusCode": 200,
            "body": json.dumps({
                "result": result.get('result'),
                "execution_id": execution_id,
                "status": "COMPLETED"
            }),
            "headers": {
                "Content-Type": "application/json"
            }
        }
        
    except Exception as e:
        import traceback
        error_trace = traceback.format_exc()
        print(f"Erro: {str(e)}")
        print(f"Traceback: {error_trace}")
        return {
            "statusCode": 500,
            "body": json.dumps({
                "error": str(e),
                "traceback": error_trace
            }),
            "headers": {
                "Content-Type": "application/json"
            }
        }


def get_access_token(client_id, client_secret):
    """
    Obtém o token de acesso da API da StackSpot
    """
    token_url = "https://idm.stackspot.com/zup/oidc/oauth/token"
    token_headers = {"Content-Type": "application/x-www-form-urlencoded"}
    token_data = {
        "grant_type": "client_credentials",
        "client_id": client_id,
        "client_secret": client_secret
    }
    
    try:
        token_response = requests.post(
            token_url, 
            headers=token_headers, 
            data=urllib.parse.urlencode(token_data)
        )
        token_response.raise_for_status()
        response_json = token_response.json()
        print(f"Resposta do token: {json.dumps(response_json)}")
        
        if 'access_token' not in response_json:
            raise Exception(f"Token não encontrado na resposta: {response_json}")
            
        return response_json['access_token']
    except requests.exceptions.RequestException as e:
        print(f"Erro na requisição do token: {str(e)}")
        if hasattr(e, 'response') and e.response:
            print(f"Resposta de erro: {e.response.text}")
        raise Exception(f"Erro ao obter token de acesso: {str(e)}")

def execute_quick_command(access_token, quick_command_slug, input_data, execution_tag=None):
    
    exec_url = f"https://genai-code-buddy-api.stackspot.com/v1/quick-commands/create-execution/{quick_command_slug}"
    exec_headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    exec_body = {
        "input_data": input_data
    }
    if execution_tag:
        exec_body["execution_tag"] = execution_tag
    
    try:
        print(f"Enviando requisição para: {exec_url}")
        print(f"Headers: {exec_headers}")
        print(f"Body: {json.dumps(exec_body)}")
        
        exec_response = requests.post(exec_url, headers=exec_headers, json=exec_body)
        exec_response.raise_for_status()
        
        # Verifica se a resposta é uma string direta ou um objeto JSON
        content_type = exec_response.headers.get('Content-Type', '')
        if 'application/json' in content_type:
            response_json = exec_response.json()
            print(f"Resposta da execução (JSON): {json.dumps(response_json)}")
            
            if isinstance(response_json, dict) and 'execution_id' in response_json:
                return response_json['execution_id']
            else:
                # Se for um JSON mas não tiver a chave execution_id
                # Verifica se o próprio JSON é uma string que pode ser o execution_id
                if isinstance(response_json, str):
                    print(f"Usando resposta JSON string como execution_id: {response_json}")
                    return response_json
                else:
                    raise Exception(f"Formato de resposta inesperado: {response_json}")
        else:
            # Se não for JSON, assume que o texto da resposta é o execution_id
            execution_id = exec_response.text.strip('"')  # Remove aspas se existirem
            print(f"Resposta da execução (texto): {execution_id}")
            return execution_id
            
    except requests.exceptions.RequestException as e:
        print(f"Erro na requisição de execução: {str(e)}")
        if hasattr(e, 'response') and e.response:
            print(f"Resposta de erro: {e.response.text}")
        raise Exception(f"Erro ao executar Quick Command: {str(e)}")

def monitor_execution(access_token, execution_id, max_retries=30, retry_interval=2):
    """
    Monitora o status da execução do Quick Command
    """
    callback_url = f"https://genai-code-buddy-api.stackspot.com/v1/quick-commands/callback/{execution_id}"
    callback_headers = {"Authorization": f"Bearer {access_token}"}
    
    print(f"Monitorando execução em: {callback_url}")
    
    for attempt in range(max_retries):
        try:
            print(f"Tentativa {attempt+1} de {max_retries}")
            callback_response = requests.get(callback_url, headers=callback_headers)
            callback_response.raise_for_status()
            
            try:
                data = callback_response.json()
                print(f"Resposta do callback: {json.dumps(data)}")
                
                # Verifica se a resposta tem a estrutura esperada
                progress = data.get('progress', {})
                print(f"Progresso: {json.dumps(progress)}")
                
                # Verificar se a execução foi concluída
                if progress.get('execution_percentage') == 1.0 and progress.get('status') == 'COMPLETED':
                    return data
                
                # Verificar se houve erro na execução
                if progress.get('status') == 'ERROR':
                    raise Exception(f"Erro na execução do Quick Command: {data.get('error_message', 'Erro desconhecido')}")
            except json.JSONDecodeError:
                # Se a resposta não for um JSON válido
                print(f"Resposta não é um JSON válido: {callback_response.text}")
                
            # Aguardar antes de verificar novamente
            print(f"Aguardando {retry_interval} segundos antes da próxima verificação")
            time.sleep(retry_interval)
            
        except requests.exceptions.RequestException as e:
            print(f"Tentativa {attempt+1} falhou: {str(e)}")
            if hasattr(e, 'response') and e.response:
                print(f"Resposta de erro: {e.response.text}")
            time.sleep(retry_interval)
    
    raise Exception(f"Tempo limite excedido após {max_retries} tentativas")
