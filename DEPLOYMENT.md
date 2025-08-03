# Trustify - Scripts de Despliegue

Este documento explica cómo desplegar los contratos del sistema Trustify en Anvil usando Foundry.

## Prerequisitos

1. **Foundry instalado**
2. **Anvil corriendo** en una terminal:
   ```bash
   anvil
   ```
3. **Variables de entorno configuradas** en tu archivo `.env`:
   ```
   ANVIL_RPC_URL=http://127.0.0.1:8545
   PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
   WALLET_ADDRESS=0x7abe56acb5f2af2fb37a26a1b61998ccc2994989
   ```

## Scripts Disponibles

### 1. Despliegue Individual de Contratos

#### InstitutionDAO
```bash
forge script script/DeployInstitutionDAO.s.sol:DeployInstitutionDAO --rpc-url $ANVIL_RPC_URL --private-key $PRIVATE_KEY --broadcast
```

#### DocumentSignatureManager
```bash
# Sin dependencias (solo deploy)
forge script script/DeployDocumentSignatureManager.s.sol:DeployDocumentSignatureManager --rpc-url $ANVIL_RPC_URL --private-key $PRIVATE_KEY --broadcast

# Con InstitutionDAO (incluye initialize)
forge script script/DeployDocumentSignatureManager.s.sol:DeployDocumentSignatureManager --rpc-url $ANVIL_RPC_URL --private-key $PRIVATE_KEY --broadcast --sig "runWithInstitutionDAO(address)" <INSTITUTION_DAO_ADDRESS>
```

#### DocumentNFT
```bash
# Solo deploy
forge script script/DeployDocumentNFT.s.sol:DeployDocumentNFT --rpc-url $ANVIL_RPC_URL --private-key $PRIVATE_KEY --broadcast

# Con dependencias (incluye initialize)
forge script script/DeployDocumentNFT.s.sol:DeployDocumentNFT --rpc-url $ANVIL_RPC_URL --private-key $PRIVATE_KEY --broadcast --sig "runWithDependencies(address,address)" <SIGNATURE_MANAGER_ADDRESS> <INSTITUTION_DAO_ADDRESS>
```

#### DocumentWorkflow
```bash
# Solo deploy
forge script script/DeployDocumentWorkflow.s.sol:DeployDocumentWorkflow --rpc-url $ANVIL_RPC_URL --private-key $PRIVATE_KEY --broadcast

# Con dependencias (incluye initialize)
forge script script/DeployDocumentWorkflow.s.sol:DeployDocumentWorkflow --rpc-url $ANVIL_RPC_URL --private-key $PRIVATE_KEY --broadcast --sig "runWithDependencies(address,address,address)" <DOCUMENT_NFT_ADDRESS> <SIGNATURE_MANAGER_ADDRESS> <INSTITUTION_DAO_ADDRESS>
```

#### DocumentFactory
```bash
forge script script/DeployDocumentFactory.s.sol:DeployDocumentFactory --rpc-url $ANVIL_RPC_URL --private-key $PRIVATE_KEY --broadcast
```

### 2. Despliegue del Sistema Completo

**Recomendado**: Despliegue todo el sistema de una vez con todas las dependencias configuradas:

```bash
forge script script/DeployFullSystem.s.sol:DeployFullSystem --rpc-url $ANVIL_RPC_URL --private-key $PRIVATE_KEY --broadcast
```

O solo el sistema core sin factory:
```bash
forge script script/DeployFullSystem.s.sol:DeployFullSystem --rpc-url $ANVIL_RPC_URL --private-key $PRIVATE_KEY --broadcast --sig "deployCoreSystem()"
```

### 3. Configuración Post-Despliegue

Después del despliegue, puedes configurar roles adicionales:

```bash
# Primero agrega las direcciones de los contratos a tu .env:
export INSTITUTION_DAO_ADDRESS=<address>
export SIGNATURE_MANAGER_ADDRESS=<address>
export DOCUMENT_NFT_ADDRESS=<address>
export DOCUMENT_WORKFLOW_ADDRESS=<address>
export DOCUMENT_FACTORY_ADDRESS=<address>

# Luego ejecuta la configuración:
forge script script/ConfigureSystem.s.sol:ConfigureSystem --rpc-url $ANVIL_RPC_URL --private-key $PRIVATE_KEY --broadcast

# Para datos de muestra:
forge script script/ConfigureSystem.s.sol:ConfigureSystem --rpc-url $ANVIL_RPC_URL --private-key $PRIVATE_KEY --broadcast --sig "setupSampleData()"
```

## Orden de Dependencias

Si decides hacer despliegue manual paso a paso, el orden correcto es:

1. **InstitutionDAO** (sin dependencias)
2. **DocumentSignatureManager** (depende de InstitutionDAO)
3. **DocumentNFT** (depende de InstitutionDAO y SignatureManager)
4. **DocumentWorkflow** (depende de todos los anteriores)
5. **DocumentFactory** (independiente, pero puede usar los otros)

## Verificación

Después del despliegue, puedes verificar que todo funciona:

```bash
# Verificar que los contratos están desplegados
cast code <CONTRACT_ADDRESS> --rpc-url $ANVIL_RPC_URL

# Verificar roles (ejemplo con InstitutionDAO)
cast call <INSTITUTION_DAO_ADDRESS> "hasRole(bytes32,address)" "0x0000000000000000000000000000000000000000000000000000000000000000" $WALLET_ADDRESS --rpc-url $ANVIL_RPC_URL
```

## Troubleshooting

### Error: "Transaction reverted"
- Verifica que Anvil esté corriendo
- Verifica que la private key sea correcta
- Verifica que tengas suficiente ETH (Anvil da ETH gratis)

### Error: "Contract already deployed"
- Si usas el Factory para desplegar instituciones, verifica que el nombre de la institución sea único

### Error: "Missing dependency"
- Verifica que hayas desplegado las dependencias en el orden correcto
- Usa el script `DeployFullSystem.s.sol` para evitar problemas de dependencias

## Comandos Útiles

```bash
# Ver logs detallados
forge script <script> --rpc-url $ANVIL_RPC_URL --private-key $PRIVATE_KEY --broadcast -vvv

# Dry run (simular sin desplegar)
forge script <script> --rpc-url $ANVIL_RPC_URL --private-key $PRIVATE_KEY

# Usar archivo .env directamente
forge script <script> --env-file .env --broadcast
```
