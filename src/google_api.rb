require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'google/api_client/auth/file_storage'

class GoogleApi
  CLIENT_SECRETS_FILE = 'auth_file/client_secrets.json'.freeze
  CREDENTIAL_STORE_FILE = 'auth_file/credential_store.json'.freeze
  API_SCOPE = ['https://www.googleapis.com/auth/drive'].freeze
  APPLICATION_NAME = 'google_drive_files'.freeze

  attr_reader :client, :file_storage

  def initialize
    @client = Google::APIClient.new(application_name: APPLICATION_NAME)
    @file_storage = Google::APIClient::FileStorage.new(CREDENTIAL_STORE_FILE)
  end

  def auth
    return set_auth if authorized?
    client_secrets = Google::APIClient::ClientSecrets.load(CLIENT_SECRETS_FILE)
    freshed_auth(client_secrets)
  end

  private

  def authorized?
    !file_storage.authorization.nil?
  end

  def freshed_auth(secret_file)
    flow = Google::APIClient::InstalledAppFlow.new(
      client_id: secret_file.client_id,
      client_secret: secret_file.client_secret,
      scope: API_SCOPE
    )
    client.authorization = flow.authorize(file_storage)
    client
  end

  def set_auth
    client.authorization = file_storage.authorization
    client
  end
end
