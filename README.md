# rxshPwnWifi

Herramienta automatizada en Bash diseñada para la auditoría de redes inalámbricas y pruebas de penetración en entornos controlados. Este script agiliza la captura de handshakes WPA/WPA2 y la ejecución de ataques PMKID (ClientLess), integrando utilidades estándar del sector en un flujo de trabajo interactivo.

> **Advertencia Legal (Disclaimer):**
> Este proyecto ha sido desarrollado con fines estrictamente educativos y para la evaluación de seguridad de redes propias o con autorización explícita. El uso de esta herramienta para interceptar o atacar redes sin el consentimiento previo y por escrito de sus propietarios es ilegal. El autor no se hace responsable del mal uso o de los daños derivados de la utilización de este código.

## Características

* **Gestión Automática de Dependencias:** Verifica e instala herramientas faltantes en el sistema de forma transparente.
* **Evasión Básica:** Implementa *MAC spoofing* automático (`macchanger`) al iniciar la interfaz en modo monitor para mantener el anonimato durante la auditoría.
* **Ataque Handshake:** Automatiza el escaneo del espectro (`airodump-ng`), la desautenticación dirigida (`aireplay-ng`) y la posterior captura del Handshake WPA para cracking offline.
* **Ataque PMKID:** Ejecuta la captura de PMKID sin necesidad de clientes conectados usando `hcxdumptool` y extrae los hashes en formato compatible para `hashcat`.

## Requisitos Previos

El script debe ejecutarse con privilegios de **root** y depende de los siguientes paquetes. Si no están en el sistema, el script intentará instalarlos mediante `apt`:

* `aircrack-ng` (suite principal)
* `macchanger` (ofuscación de dirección MAC)
* `xterm` (ejecución de ventanas de monitorización en paralelo)
* `hcxtools` y `hcxdumptool` (para ataque ClientLess PMKID)
* `hashcat` (para el proceso de fuerza bruta)
* Diccionario `rockyou.txt` (ubicado por defecto en `/usr/share/wordlists/rockyou.txt`)

*Nota: Es imprescindible contar con un adaptador de red Wi-Fi USB cuyo chipset soporte modo monitor e inyección de paquetes (ej. Atheros AR9271, Ralink RT3070).*

## Instalación y Uso

Clona el repositorio y otorga permisos de ejecución:

```bash
git clone https://github.com/rxsh/rxshPwnWfi.git
cd rxshPwnWfi
chmod +x rxshPwnWfi.sh
