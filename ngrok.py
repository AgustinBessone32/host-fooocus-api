from pyngrok import ngrok
import os


ngrok.set_auth_token(os.environ['NGROK_AUTH_TOKEN'])


url = ngrok.connect(os.environ['FOOOCUS_PORT'])
print('API is publicly accessible at:', url)