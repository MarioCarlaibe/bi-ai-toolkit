# BI AI Toolkit (Power BI + SQL Server + DAX)

Biblioteca prática para acelerar análises e dashboards (principalmente **SLA** e **produtividade**) usando:

- **SQL Server (T-SQL)** para preparar datasets (prontos para Power BI)
- **Power BI** para modelagem/visuais
- **DAX** para KPIs reutilizáveis
- **Prompts** para padronizar o uso de IA (Copilot) no dia a dia

> Este repositório é um **toolkit** (biblioteca). Ele não “roda” como um app único: você executa as queries no seu SQL Server e usa os arquivos como base para montar o modelo e as medidas no Power BI.

---

## O que você encontra aqui

- Queries SQL de referência (foco Power BI): [sql/queries](sql/queries)
- Medidas DAX reutilizáveis: [dax/measures](dax/measures)
- Prompts para Copilot/IA: [prompts](prompts)
- Template de dashboard de SLA (layout + checklist): [templates/dashboard.md](templates/dashboard.md)
- Documentação e padrões: [docs](docs)

Arquivos “âncora” do projeto:

- Contexto do toolkit (como a IA deve se comportar): [contexto.md](contexto.md)
- Padrões de SLA: [padroes_sla.md](padroes_sla.md)
- Padrões de reutilização/nomeação: [docs/references/padroes-reutilizacao.md](docs/references/padroes-reutilizacao.md)

---

## Pré-requisitos

- Power BI Desktop
- Acesso a um SQL Server (ou Azure SQL) com as tabelas de demandas
- VS Code (recomendado) para navegar/editar os arquivos
- (Opcional, mas recomendado) GitHub Copilot Chat no VS Code

---

## Quickstart (SLA end-to-end)

### 1) Clonar e abrir no VS Code

```bash
git clone <URL_DO_REPO>
cd bi-ai-toolkit
code .
```

### 2) Escolher uma query base (dataset)

Para análises de SLA, comece por um dataset no **grão por demanda**:

- Dataset base (recomendado para modelagem e DAX): [sql/queries/sla__dataset_demandas.sql](sql/queries/sla__dataset_demandas.sql)
- Exemplo agregado (tempo médio por setor): [sql/queries/sla__tempo_medio_por_setor.sql](sql/queries/sla__tempo_medio_por_setor.sql)

Abra a query, **ajuste nomes de tabela/colunas** para o seu modelo e execute no seu ambiente SQL.

### 3) Conectar o Power BI no SQL Server

No Power BI Desktop:

1. **Obter dados** → **SQL Server**
2. (Recomendado) crie uma **view** no banco com base na query do toolkit e conecte o Power BI nessa view
3. Alternativa: use **Opções avançadas** e cole a query (observação abaixo sobre múltiplas instruções)

Observação importante sobre parâmetros e `DECLARE`:
- Algumas formas de conexão do Power BI aceitam apenas um `SELECT` (sem `DECLARE`/CTE múltipla). Se isso acontecer:
	- transforme a query em **view** no SQL Server, ou
	- substitua `DECLARE` por valores fixos na etapa de desenvolvimento, ou
	- use Power Query com `Value.NativeQuery` para passar parâmetros de forma controlada.

> Dica: o toolkit prioriza filtros sargáveis (ex.: `>= @DataInicio` e `< DATEADD(day, 1, @DataFim)`) para ajudar performance.

### 4) Criar medidas DAX de SLA

Use como base as medidas em:

- KPIs DAX (SLA): [dax/measures/sla__kpis.dax](dax/measures/sla__kpis.dax)

Essas medidas assumem uma tabela fato chamada `Demandas` com colunas como `DataAbertura`, `DataConclusao` e `DataVencimento` (ajuste nomes no Power BI, se necessário).

### 5) Montar o dashboard

Siga o guia/layout/checklist:

- Template de dashboard de SLA: [templates/dashboard.md](templates/dashboard.md)

---

## Como usar com Copilot (IA) sem perder padrão

1. Comece pelo contexto do projeto: [contexto.md](contexto.md)
2. Para SQL e DAX, use os prompts base:
	 - SQL: [prompts/sql.txt](prompts/sql.txt)
	 - DAX: [prompts/dax.txt](prompts/dax.txt)
	 - Análise/insights: [prompts/analise.txt](prompts/analise.txt)
3. Sempre que possível, derive de itens já existentes (biblioteca) antes de criar do zero.

### Skill (Copilot)

Existe uma skill pronta para gerar um “kit” reutilizável (dataset SQL + medidas DAX + insights) focado em Power BI:

- Skill: [.github/skills/powerbi-advanced-pattern](.github/skills/powerbi-advanced-pattern)

Guia rápido de aplicação (passo a passo):

- [.github/skills/powerbi-advanced-pattern/references/como-aplicar.md](.github/skills/powerbi-advanced-pattern/references/como-aplicar.md)

---

## Estrutura do repositório

```text
prompts/    → prompts reutilizáveis para IA (SQL/DAX/análise)
sql/        → queries SQL (foco em dataset para Power BI)
dax/        → medidas DAX reutilizáveis
templates/  → templates e checklists de dashboard
docs/       → guias e referências (padrões, checklists, convenções)
```

---

## Padrões e convenções (importante para reuso)

- Use nomes em minúsculo e com `__` separando domínio e objetivo (ex.: `sla__dataset_demandas.sql`).
- Em SQL:
	- evite `SELECT *`
	- traga colunas “prontas para análise” (ex.: `TempoAtendimentoMinutos`, `StatusSLA`, `FlagAtraso`)
	- aplique filtro por período cedo e de forma sargável
- Em DAX:
	- prefira medidas (não colunas calculadas)
	- use `DIVIDE()` para percentuais

Referência completa:

- [docs/references/padroes-reutilizacao.md](docs/references/padroes-reutilizacao.md)

---

## Como contribuir (adicionar novos itens)

Boas práticas para manter o toolkit “biblioteca”:

1. **Um arquivo = um caso de uso** (evite arquivos gigantes)
2. Coloque um header no topo do `.sql` com:
	 - objetivo, fonte, granularidade, data driver, parâmetros e colunas de saída
3. Mantenha consistência de nomes e do grão (principalmente em datasets para Power BI)

Sugestões rápidas:

- SQL: coloque em [sql/queries](sql/queries)
- DAX: coloque em [dax/measures](dax/measures)
- Prompt: coloque em [prompts](prompts) (snippets em [prompts/snippets](prompts/snippets))

---

## Próximos passos recomendados

- Padronizar o nome real da tabela fato no Power BI (`Demandas`) e criar uma tabela calendário.
- Começar o modelo pelo dataset [sql/queries/sla__dataset_demandas.sql](sql/queries/sla__dataset_demandas.sql) e só depois derivar agregações.

---

## Observação sobre publicação

Este repositório não inclui um arquivo `LICENSE`. Se a intenção for uso público/externo no GitHub, vale definir uma licença e remover/anonimizar exemplos que contenham referências internas.
