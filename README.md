# Gerenciador de Produtos

O desafio consiste em criar uma aplicação completa para **gerenciamento de produtos**, com funções de **cadastrar, editar, excluir e listar**.  
O sistema será dividido em duas partes:

1. **API Backend** – responsável por processar as requisições e interagir com o banco de dados (**SQL Server** ou **PostgreSQL**) para persistir os dados.  
2. **Frontend VCL** – interface para o usuário, feita com **Visual Component Library (VCL)**, exibindo, cadastrando e editando produtos.

A API deve seguir os princípios de **Programação Orientada a Objetos (POO)** e utilizar um **ORM** para facilitar o acesso ao banco de dados.  
No frontend, o formulário de cadastro será exibido em uma janela modal e a estilização deve ser feita **sem bibliotecas externas**.
Também serão implementados **testes unitários** com **DUnitX** para validar a qualidade do código.

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
  
O backend processa as requisições relacionadas a produtos, recebe pedidos do frontend, aplica regras, acessa o banco de dados e retorna respostas padronizadas.

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
<summary><strong>2) Visão geral</strong></summary>

- **Stack**: .NET 9, ASP.NET Core, EF Core, PostgreSQL  
- **Endpoints**: `/api/v1/*`  
- **Swagger**: documentação e testes via navegador

**Camadas**
- **API**: controllers e configs  
- **Application**: services  
- **Domain**: entidades e modelos  
- **Infrastructure**: banco, mappings, repositórios e migrations
</details>

<details>
<summary><strong>3) Entidade Produto</strong></summary>

Campos: `Id`, `Code`, `Name`, `Description?`, `Price`, `Stock`, `CreatedAt`, `UpdatedAt`  

**Regras**
- Nome obrigatório  
- Preço > 0  
- Estoque ≥ 0
</details>

<details>
<summary><strong>4) Endpoints</strong></summary>

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
<summary><strong>5) Fluxo interno</strong></summary>

1. Controller recebe requisição  
2. Chama Service (regra de negócio)  
3. Service usa Repository + UnitOfWork para salvar/buscar no banco  
4. Retorna resposta padrão
</details>

<details>
<summary><strong>6) Glossário</strong></summary>

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
