---
name: powerbi-advanced-pattern
description: 'Crie um padrão avançado e reutilizável de análise para Power BI combinando SQL Server + DAX e gerando insights automaticamente. Use quando: precisar montar um kit de dashboard (dataset SQL + medidas DAX + medidas de insights/texto para Smart Narrative) para SLA, produtividade, backlog, atrasos ou volume; quando quiser padronizar filtros por período e análise por equipe/setor; quando quiser reusar bibliotecas em novos dashboards.'
argument-hint: 'Informe tema (SLA/produtividade), tabelas/colunas, data driver (abertura/conclusão), dimensão (equipe/setor), meta SLA e período padrão.'
user-invocable: true
---

# Power BI Advanced Pattern (SQL + DAX + Insights)

Skill para estruturar um **kit reutilizável** composto por:
1) Query SQL (SQL Server) pronta para alimentar o Power BI com filtros por período e agregações no grão correto.
2) Medidas DAX (KPIs) com boas práticas (VAR, DIVIDE, performance).
3) Medidas DAX de **insights automáticos** (texto/alertas) para usar em Smart Narrative e cartões.
4) Checklist de validação e publicação.

## Quando usar
- Criar um novo dashboard de **SLA** ou **produtividade** e quer reaproveitar padrões.
- Transformar uma análise ad hoc em **biblioteca** (SQL + DAX) com naming e metadados.
- Precisa de análise **por período** (dia/semana/mês) e **por equipe/setor**.
- Quer medidas que sinalizam automaticamente **alertas** (ex.: taxa de atraso subindo) e geram um **resumo textual**.

## Entradas necessárias (coletar antes de gerar qualquer coisa)
1) **Tema**: SLA / produtividade / backlog / volume / qualidade.
2) **Fonte (SQL)**: banco/schema, tabela(s) fato, chaves e joins.
3) **Datas**:
   - Data driver do período (abertura / conclusão / referência).
   - Coluna de vencimento (se existir) e regra de atraso.
4) **Dimensões**: Setor e/ou Equipe (coluna direta ou dimensão relacionada).
5) **Meta**:
   - Meta SLA (ex.: X horas/dias) e definição de “dentro do SLA”.
6) **Grão**:
   - Grão desejado (por demanda, por dia, por mês, por equipe…).

Se faltar algo, faça no máximo 5 perguntas objetivas e aguarde.

## Procedimento (passo a passo)

### Passo 1 — Definir o contrato do dataset (SQL)
- Defina a **tabela de saída** e o grão (ex.: por demanda concluída; ou por dia+equipe com agregação).
- Garanta filtros por período com parâmetros (`@DataInicio`, `@DataFim`) de forma sargável.
- Inclua colunas mínimas para suportar análises por equipe/setor e por status.

Use como base o template: [SQL dataset template](./assets/sql_dataset_template.sql)

### Passo 2 — Gerar/atualizar a query na biblioteca
- Salve em `sql/queries/<tema>__<objetivo>.sql`.
- Coloque um header com: objetivo, fonte, grão, data driver, parâmetros e colunas de saída.

### Passo 3 — Definir o pacote de medidas (DAX)
- Crie medidas base (contagens e tempo) e derive KPIs (taxas, médias, % SLA).
- Garanta que as medidas funcionem com filtros por período (tabela calendário) e por equipe/setor (dimensão no visual/slicer).

Use como base: [DAX KPI template](./assets/dax_kpis_template.dax)

### Passo 4 — Adicionar insights automáticos (DAX)
- Crie medidas de alerta (0/1) e uma medida de texto com resumo (para Smart Narrative).
- O texto deve ser curto e orientado a ação.

Use como base: [DAX insights template](./assets/dax_insights_template.dax)

### Passo 5 — Aplicar o checklist
Use o checklist: [Insights checklist](./assets/insights_checklist.md)

## Padrões obrigatórios
- SQL: evitar `SELECT *`, usar aliases claros, filtrar cedo, manter sargabilidade no filtro de data.
- DAX: medidas (não colunas), `VAR` e `DIVIDE`, evitar iteradores quando não necessários.
- Reuso: antes de criar novo arquivo, procurar por padrão existente e derivar.

## Saídas esperadas
- 1 arquivo SQL na biblioteca (em `sql/queries`).
- 1 arquivo DAX na biblioteca (em `dax/measures`).
- Opcional: atualização de template/guia em `templates/` e referência em `docs/references/`.
