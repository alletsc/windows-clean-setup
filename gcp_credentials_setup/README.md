# GCP Credentials Setup

Script para configurar rapidamente a credencial da Service Account do Google Cloud no WSL/Ubuntu, pronta para uso com DBT, Google Cloud CLI, Python e demais ferramentas.

---

## Quando usar este script?

- **Somente quando você BAIXAR uma nova credencial JSON do Google Cloud!**
- Geralmente, só será necessário rodar uma vez por computador.
- Se trocar de máquina, renovar ou baixar uma nova chave, rode novamente.

---

## 🛠️ Como usar

1. **Baixe a credencial JSON da sua Service Account pelo console do Google Cloud.**
2. Salve o arquivo na pasta padrão de Downloads do Windows.

3. **No WSL/Ubuntu, execute:**

```bash
   cd ~/gcp_credentials_setup
   bash setup_gcp_credentials.sh
````

4. O script irá:

   * Copiar automaticamente o arquivo JSON mais recente dos Downloads do Windows para `~/.gcp/credentials.json`
   * Garantir as permissões corretas para segurança
   * Adicionar (se necessário) a variável de ambiente no seu `.zshrc`
   * Mostrar uma mensagem de sucesso

5. **Finalize recarregando seu terminal ou rodando:**

   ```bash
   source ~/.zshrc
   ```

---

## ℹ️ Observações

* O script foi projetado para WSL (Ubuntu), mas pode funcionar em Linux desktop se ajustar o caminho dos Downloads.
* Depois de configurado, você não precisará rodar de novo, a menos que baixe outra credencial.
* O DBT, o Google Cloud CLI e demais ferramentas passarão a usar a credencial automaticamente!

---

## ⚠️ Segurança

Nunca compartilhe ou versiona o arquivo `credentials.json`.
Mantenha-o apenas em `~/.gcp/` no seu usuário, protegido.