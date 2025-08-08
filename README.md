# Gerenciador de Produtos

O desafio consiste em criar uma aplicação completa para **gerenciamento de produtos**, com funções de **cadastrar, editar, excluir e listar**.  
O sistema será dividido em duas partes:

1. **API Backend** – responsável por processar as requisições e interagir com o banco de dados (**SQL Server** ou **PostgreSQL**) para persistir os dados.  
2. **Frontend VCL** – interface para o usuário, feita com **Visual Component Library (VCL)**, exibindo, cadastrando e editando produtos.

A API segue os princípios de **Programação Orientada a Objetos (POO)** e utiliza um **ORM** para acesso ao banco.  
No frontend, a inclusão de produtos é feita em janela modal, e a edição é realizada diretamente na grade (inline).  
A estilização é feita **sem bibliotecas externas**.  
Também há a previsão de **testes unitários** com **DUnitX**.

---

### **Requisitos**
- **API Backend**: incluir, atualizar, excluir e listar produtos.
- **Frontend VCL**: cadastrar, editar e excluir produtos pela interface gráfica.
- **Estilização**: sem bibliotecas/frameworks externos.
- **ORM**: livre escolha.
- **Testes Unitários**: com **DUnitX**.

---

### **Checklist**
- [x] Inclusão de produtos  
- [x] Exclusão de produtos  
- [x] Atualização de produtos  
- [x] Listagem de produtos  
- [ ] Implementação de testes unitários com DUnitX  

## API Backend

<details>
<summary><strong>Documentação</strong></summary>
  
O backend processa requisições de produtos, aplica regras, acessa o banco de dados e retorna respostas padronizadas.

**Requisitos**
- .NET SDK 9.0+
- PostgreSQL
- Visual Studio, VS Code ou Rider

<details>
<summary><strong>1) Como rodar</strong></summary>

**Configurar banco**
1. No arquivo `GerenciadorDeProdutos.API/appsettings.json`, ajuste `Database.Postgres.ConnectionString` com host, porta, banco, usuário e senha.

**Criar tabelas e seed**
```bash
dotnet tool install --global dotnet-ef
dotnet ef database update --project GerenciadorDeProdutos.Infrastructure --startup-project GerenciadorDeProdutos.API
```

**Executar**
- **VS**: selecione perfil **DEV** ou **PROD** e pressione **F5**.
- **CLI**:
```bash
dotnet run --project GerenciadorDeProdutos.API
```
A API sobe em `http://localhost:5289` com Swagger.
</details>

<details>
<summary><strong>2) Entidade Produto</strong></summary>

Campos: `Id`, `Code`, `Name`, `Description?`, `Price`, `Stock`, `CreatedAt`, `UpdatedAt`  

**Regras**
- Nome obrigatório  
- Preço > 0  
- Estoque ≥ 0
</details>

<details>
<summary><strong>3) Endpoints</strong></summary>

Base: `/api/v1/products`

| Método | Rota       | Ação                |
|--------|------------|--------------------|
| GET    | `/`        | Listar todos       |
| GET    | `/{id}`    | Buscar por ID      |
| POST   | `/`        | Criar produto      |
| PUT    | `/`        | Atualizar produto  |
| DELETE | `/{id}`    | Excluir um         |
| DELETE | `/batch`   | Excluir vários     |

**Resposta padrão**: `statusCode`, `title`, `data`, `errors`
</details>

<details>
<summary><strong>4) Fluxo interno</strong></summary>

1. Controller recebe requisição  
2. Chama Service (regra de negócio)  
3. Service usa Repository + UnitOfWork para salvar/buscar no banco  
4. Retorna resposta padrão
</details>

<details>
<summary><strong>5) Glossário</strong></summary>

- **API**: serviço que recebe e responde  
- **Endpoint**: endereço da API  
- **ORM**: mapeia objetos e banco  
- **Entity**: estrutura de dados  
- **Service**: regra de negócio  
- **Repository**: acesso ao banco  
- **UnitOfWork**: garante transações  
- **Swagger**: interface de teste
</details>
</details>

## Frontend VCL

<details>
<summary><strong>Documentação</strong></summary>

O **Frontend VCL** é a aplicação em **Delphi (VCL)** que consome a API do Backend para listar, incluir e editar produtos.

**Requisitos**
- Delphi (ex.: 10.3+)
- Windows
- API Backend rodando em `http://localhost:5289` (ou a URL configurada)

---

<details>
<summary><strong>1) Como rodar</strong></summary>

**Configurar URL da API**
1. Abra o projeto no Delphi.
2. Ajuste a **Base URL** para apontar para a API (ex.: `http://localhost:5289/api/v1`).

**Executar**
- Pressione **F9** no Delphi.
- A tela principal abrirá com a lista de produtos carregada via API.

**Pré-condição**
- API deve estar em execução antes de abrir o Frontend.
</details>

<details>
<summary><strong>2) Estrutura</strong></summary>

- **Controllers**: fazem chamadas HTTP para a API.
- **Entities/Models**: representam os dados do produto.
- **Forms**:
  - **Principal**: acesso ao módulo de produtos.
  - **Produtos**: listagem em grid com edição inline.
  - **Cadastro**: modal para inclusão.

</details>

<details>
<summary><strong>3) Funcionalidades</strong></summary>

- **Buscar**: carrega produtos do Backend.
- **Incluir**: abre modal para cadastro.
- **Editar**: diretamente na grid (inline).
- **Excluir**: individual ou em lote (checkbox).
- **Feedback**: mensagens de sucesso/erro conforme retorno da API.

</details>

</details>
