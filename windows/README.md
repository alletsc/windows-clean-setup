# Instalação Automatizada do WSL 2 + Ubuntu no Windows

Este repositório contém um **setup automatizado e confiável** para instalar o WSL 2 e o Ubuntu em qualquer máquina Windows 10/11.
O processo é **dividido em duas etapas** para evitar erros comuns relacionados à ativação de recursos e reinicialização.

---

## 📦 Arquivos

* **wsl\_enable.ps1**
  Habilita os recursos do Windows necessários para o WSL 2 e reinicia o computador.
* **wsl\_ubuntu\_install.ps1**
  Instala o Ubuntu no WSL 2 e realiza ajustes finais, incluindo fallback para instalação via Microsoft Store se necessário.
* **run\_wsl\_setup.bat**
  Script em lote que orquestra a execução dos dois scripts PowerShell, lidando com permissões de administrador e marcação de progresso.

---

## 🚀 Como usar

**1. Baixe os três arquivos para a mesma pasta:**

* `wsl_enable.ps1`
* `wsl_ubuntu_install.ps1`
* `run_wsl_setup.bat`

**2. Execute o `run_wsl_setup.bat` como administrador.**
(Se aparecer um prompt pedindo permissão, aceite.)

* O script vai:

  1. Rodar o `wsl_enable.ps1` para habilitar os recursos necessários.
  2. Reiniciar o computador automaticamente.

**3. Após o reboot, execute novamente o `run_wsl_setup.bat` como administrador.**

* Agora ele irá:

  1. Rodar o `wsl_ubuntu_install.ps1` para instalar/configurar o Ubuntu.
  2. Reiniciar o computador ao final do processo.

**4. Após o segundo reboot, procure “Ubuntu” no menu iniciar e abra.**

* Siga as instruções para criar o usuário e senha do Ubuntu (passo obrigatório do WSL).
* Pronto! Seu ambiente WSL 2 com Ubuntu estará operacional.

---

## ℹ️ Observações Importantes

* Execute sempre os scripts **como administrador** para evitar falhas de permissão.
* O processo é seguro e não apaga dados, mas recomenda-se fechar arquivos antes das reinicializações.
* Caso encontre erros, consulte os arquivos de log gerados na mesma pasta dos scripts (`wsl_enable_log.txt` e `wsl_install_log.txt`).

---

## 🛠️ Troubleshooting

* **Não encontrou “Ubuntu” no menu iniciar após tudo?**

  * Rode manualmente `winget install -e --id Canonical.Ubuntu` como admin e abra o Ubuntu pelo menu iniciar.
* **Recurso não habilitado ou erro DISM?**

  * Verifique se está rodando o script como administrador.
* **Permissão negada ou “acesso negado”?**

  * Feche o terminal, clique com direito no `.bat` e selecione “Executar como administrador”.

---

## ✍️ Exemplo de uso

```plaintext
1. Clique com direito no arquivo run_wsl_setup.bat > Executar como administrador
2. Aguarde o PC reiniciar
3. Após o reboot, execute o run_wsl_setup.bat novamente como admin
4. Após o segundo reboot, abra o Ubuntu no menu iniciar e siga o setup inicial
```

---

**Pronto. Processo testado, à prova de falhas típicas do WSL no Windows.**
Para dúvidas técnicas, crie uma issue ou consulte o log gerado.
