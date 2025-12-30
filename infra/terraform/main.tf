locals {
  prefix = lower(var.name_prefix)
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${local.prefix}-law"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "cae" {
  name                       = "${local.prefix}-cae"
  location                   = data.azurerm_resource_group.rg.location
  resource_group_name        = data.azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
}

resource "azurerm_container_registry" "acr" {
  name                = replace("${local.prefix}acr", "-", "")
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
}

# NEW: User Assigned Identity used for ACR pulls
resource "azurerm_user_assigned_identity" "acr_pull" {
  name                = "${local.prefix}-acr-pull"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

# NEW: Grant AcrPull to the UAMI on ACR
resource "azurerm_role_assignment" "uami_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.acr_pull.principal_id
}

resource "azurerm_container_app" "api" {
  name                         = "${local.prefix}-api"
  resource_group_name          = data.azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.cae.id
  revision_mode                = "Single"

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.acr_pull.id]
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.acr_pull.id
  }
  secret {
    name                = "azure-storage-connection-string"
    key_vault_secret_id = azurerm_key_vault_secret.azure_storage_connection_string.id
    identity            = azurerm_user_assigned_identity.acr_pull.id
  }
    secret {
    name                = "azure-vision-endpoint"
    key_vault_secret_id = azurerm_key_vault_secret.azure_vision_endpoint.id
    identity            = azurerm_user_assigned_identity.acr_pull.id
  }

  secret {
    name                = "azure-vision-key"
    key_vault_secret_id = azurerm_key_vault_secret.azure_vision_key.id
    identity            = azurerm_user_assigned_identity.acr_pull.id
  }
    secret {
    name                = "azure-openai-endpoint"
    key_vault_secret_id = azurerm_key_vault_secret.azure_openai_endpoint.id
    identity            = azurerm_user_assigned_identity.acr_pull.id
  }

  secret {
    name                = "azure-openai-api-key"
    key_vault_secret_id = azurerm_key_vault_secret.azure_openai_api_key.id
    identity            = azurerm_user_assigned_identity.acr_pull.id
  }

  secret {
    name                = "azure-openai-deployment"
    key_vault_secret_id = azurerm_key_vault_secret.azure_openai_deployment.id
    identity            = azurerm_user_assigned_identity.acr_pull.id
  }

  secret {
    name                = "docintel-endpoint"
    key_vault_secret_id = azurerm_key_vault_secret.docintel_endpoint.id
    identity            = azurerm_user_assigned_identity.acr_pull.id
  }

  secret {
    name                = "docintel-key"
    key_vault_secret_id = azurerm_key_vault_secret.docintel_key.id
    identity            = azurerm_user_assigned_identity.acr_pull.id
  }

  secret {
    name                = "azure-storage-container"
    key_vault_secret_id = azurerm_key_vault_secret.azure_storage_container.id
    identity            = azurerm_user_assigned_identity.acr_pull.id
  }
  secret {
      name                = "cosmos-endpoint"
      key_vault_secret_id = azurerm_key_vault_secret.cosmos_endpoint.id
      identity            = azurerm_user_assigned_identity.acr_pull.id
    }

  secret {
      name                = "cosmos-key"
      key_vault_secret_id = azurerm_key_vault_secret.cosmos_key.id
      identity            = azurerm_user_assigned_identity.acr_pull.id
    }

  secret {
      name                = "cosmos-db-name"
      key_vault_secret_id = azurerm_key_vault_secret.cosmos_db_name.id
      identity            = azurerm_user_assigned_identity.acr_pull.id
    }

  secret {
      name                = "cosmos-container-name"
      key_vault_secret_id = azurerm_key_vault_secret.cosmos_container_name.id
      identity            = azurerm_user_assigned_identity.acr_pull.id
    }


  template {
    container {
      name   = "api"
      image  = "${azurerm_container_registry.acr.login_server}/${var.image_name}:${var.image_tag}"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "PORT"
        value = "8000"
      }
      env {
        name        = "AZURE_STORAGE_CONNECTION_STRING"
        secret_name = "azure-storage-connection-string"
      }
      env {
        name        = "AZURE_VISION_ENDPOINT"
        secret_name = "azure-vision-endpoint"
      }

      env {
        name        = "AZURE_VISION_KEY"
        secret_name = "azure-vision-key"
      }
      env { 
        name = "AZURE_OPENAI_ENDPOINT"    
        secret_name = "azure-openai-endpoint" 
      }
      env { 
        name = "AZURE_OPENAI_API_KEY"     
        secret_name = "azure-openai-api-key" 
      }
      env { 
        name = "AZURE_OPENAI_DEPLOYMENT"  
        secret_name = "azure-openai-deployment" 
      }

      env { 
        name = "DOCINTEL_ENDPOINT"        
        secret_name = "docintel-endpoint" 
      }
      env { 
        name = "DOCINTEL_KEY"             
        secret_name = "docintel-key" 
      }

      env { 
        name = "AZURE_STORAGE_CONTAINER"  
        secret_name = "azure-storage-container" 
      }
      env {
        name        = "COSMOS_ENDPOINT"
        secret_name = "cosmos-endpoint"
      }

      env {
        name        = "COSMOS_KEY"
        secret_name = "cosmos-key"
      }

      env {
        name        = "COSMOS_DB_NAME"
        secret_name = "cosmos-db-name"
      }

      env {
        name        = "COSMOS_CONTAINER_NAME"
        secret_name = "cosmos-container-name"
      }




    }

    min_replicas = 1
    max_replicas = 10
  }

  ingress {
    external_enabled = true
    target_port      = 8000
    transport        = "auto"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  depends_on = [azurerm_role_assignment.uami_acr_pull]
}

