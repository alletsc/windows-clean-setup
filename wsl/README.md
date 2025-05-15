# WSL Dev & Python/DBT Setup

Scripts para transformar rapidamente seu Ubuntu/WSL em um ambiente de desenvolvimento moderno, produtivo e pronto para trabalhar com Python, DBT e BigQuery.

---

## 🚀 O que está incluso

- Atualização automática do sistema
- Instalação de Zsh, Oh My Zsh, Starship, plugins úteis e CLI essentials
- Configuração de aliases, navegação otimizada, integração com Windows e performance tuning para WSL
- Setup universal do Python (via pyenv), ambiente virtual isolado e instalação do DBT + adaptador BigQuery
- Pronto para múltiplos projetos DBT, navegação produtiva e terminal turbo

---

## 🛠️ Como usar

### 1. **Configuração do ambiente WSL**

Salve o script na sua home:

```bash
nano ~/wsl_config_setup.sh
````

Cole o conteúdo do script, salve e feche.
Dê permissão de execução (opcional):

```bash
chmod +x ~/wsl_config_setup.sh
```

Execute:

```bash
bash ~/wsl_config_setup.sh
```

Ou, se deu permissão:

```bash
./wsl_config_setup.sh
```

Siga as instruções na tela.
Ao final, reinicie seu terminal ou rode:

```bash
source ~/.zshrc
```

---

### 2. **Configuração do ambiente Python + DBT**

Salve o script do ambiente Python/DBT:

```bash
nano ~/setup_dbt_env.sh
```

Cole o conteúdo, salve e feche.
Execute:

```bash
bash ~/setup_dbt_env.sh
```

Crie um alias para ativar facilmente o virtualenv:

```bash
echo "alias dbtenv='source ~/dbt-env/bin/activate'" >> ~/.zshrc
source ~/.zshrc
```

Ative o ambiente sempre que for trabalhar com DBT:

```bash
dbtenv
```

Para desativar:

```bash
deactivate
```

---

### 3. **Organize seus projetos DBT**

Salve todos seus projetos em `~/projects/dbt`.
Exemplo para clonar um projeto existente:

```bash
cd ~/projects/dbt
git clone git@github.com:iplanrio/nome-do-projeto-dbt.git
cd nome-do-projeto-dbt
```

Com o ambiente ativado, rode DBT normalmente:

```bash
dbt debug
dbt build
dbt run
```

Para criar um novo projeto:

```bash
mkdir -p ~/projects/dbt && cd ~/projects/dbt
dbt init exemplo-projeto
```

---

## ℹ️ Dicas

* O virtualenv isola dependências do DBT, evitando conflitos.
* Sempre ative o ambiente (`dbtenv`) antes de trabalhar!
* Use pyenv para instalar outras versões do Python conforme necessidade.
* O script já prepara terminal, navegação e performance otimizadas.

---

## ⚠️ Aviso

Os scripts alteram seu sistema e shell (`.zshrc` ou `.bashrc`).
Revise antes de rodar para personalizar conforme seu gosto.
