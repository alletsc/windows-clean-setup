# Windows & WSL Clean Setup

Este repositório traz **scripts automatizados** para pós-formatação do Windows e configuração de ambiente de desenvolvimento no WSL (Ubuntu), focando em máxima produtividade e mínimo bloatware.

## ⚡ Funcionalidades

- Limpeza e otimização automática do Windows 10/11
- Instalação dos principais utilitários via `winget`:  
  - Google Chrome
  - OBS Studio
  - PowerToys
  - Git
  - Google Drive
  - Bulk Crap Uninstaller (BCU)
  - ExplorerPatcher
- Remoção de apps inúteis do Windows e ajustes de visual
- Instalação do WSL 2 com Ubuntu mais recente e reinicialização automática
- **Setup avançado do Ubuntu/WSL**, incluindo:
  - **Zsh** como shell padrão
  - **Oh My Zsh** com plugins modernos (autosuggestions, syntax-highlighting)
  - **Starship** prompt super-rápido e customizável
  - **Aliases produtivos** e integração com o Cursor IDE
  - Instalação de ferramentas essenciais de desenvolvimento:  
    - Git  
    - Curl  
    - jq  
    - yq  
    - tree  
    - fzf  
    - build-essential  
    - pkg-config  
    - libssl-dev, libffi-dev, libsqlite3-dev, libbz2-dev, libreadline-dev, zlib1g-dev 
    - Python 3 e pip (já incluso por padrão via Ubuntu WSL)
  - **Navi** (cheatsheet interativo para terminal)
  - **Zoxide** (navegação de diretórios inteligente)
  - Sincronização de relógio (`hwclock`) e configuração automática de timezone
  - Tunagens de performance no `.wslconfig` (memória, CPUs, swap, forwarding)
  - Criação de aliases úteis para integração entre arquivos Windows e Linux
  - Configuração do Git com boas práticas modernas

---

## 🚀 Como usar

### 1. **Limpeza e setup do Windows**

Execute como **administrador**:

```bash
windows_clean_setup.bat
````

> O `.bat` garante execução elevada e chama o script PowerShell, que faz toda a configuração automática e reinicia o PC ao final.

---

### 2. **Instalação do WSL com Ubuntu**

Execute como **administrador**:

```bash
install_wsl_ubuntu.bat
```

> Instala o WSL 2 e o Ubuntu mais recente, atualiza o kernel e reinicia o computador automaticamente.

---

### 3. **Configuração produtiva do Ubuntu/WSL**

Abra o Ubuntu (WSL) pela primeira vez, crie seu usuário Linux normalmente.
Depois, execute:

```bash
bash wsl_config_setup.sh
```

> Esse script instala e configura automaticamente Zsh, Oh My Zsh, Starship, plugins, aliases úteis, CLI essentials, tunagens de performance e sincroniza o relógio/timezone.

**Extra: Configuração de credencial do Google Cloud (BigQuery/DBT)**

---

## 📝 Observações

* Os scripts foram pensados para **rodar sem interação** (não pedem confirmação na instalação).
* O script WSL detecta automaticamente o usuário do Windows e adapta os caminhos.
* Recomenda-se reiniciar o terminal após rodar o script de configuração WSL.
* Para aplicar as tunagens de performance, execute `wsl --shutdown` no PowerShell após o setup WSL.

---

## 🛠️ Pré-requisitos

* Windows 10 ou 11 atualizado
* Powershell (pré-instalado)
* Conexão com a internet

---

## 🎯 Objetivo

Deixar o ambiente Windows + WSL enxuto, rápido e pronto para desenvolvimento com python e DBT.

---

## ⚠️ Aviso

Os scripts fazem alterações no sistema. Use por sua conta e risco!
Sempre revise os scripts antes de rodar em ambientes críticos.
