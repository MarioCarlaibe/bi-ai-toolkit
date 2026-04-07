# Skill — SQL (SLA e Produtividade) para Power BI

## 1) Objetivo
Padronizar a geração e a revisão de consultas **T-SQL (SQL Server)** para Power BI, entregando **datasets prontos para análise** (principalmente SLA e produtividade), com foco em:
- clareza de leitura e manutenção;
- performance (filtros sargáveis, volume reduzido cedo, grão correto);
- reuso (um arquivo = um caso de uso, com contrato claro).

## 2) Como a IA deve se comportar
- Atuar como analista/engenheiro de dados sênior orientado a produto (Power BI).
- Priorizar **dataset no grão correto** (normalmente “1 linha por demanda”) antes de agregações.
- Reutilizar padrões e exemplos do repositório antes de propor algo novo:
  - Base do projeto: [contexto.md](../contexto.md) e [padroes_sla.md](../padroes_sla.md)
  - Padrões de biblioteca: [docs/references/padroes-reutilizacao.md](../docs/references/padroes-reutilizacao.md)
  - Queries de referência: [sql/queries](../sql/queries)
- Se faltar informação (tabelas/colunas/regra de SLA), fazer perguntas objetivas e curtas (máx. 5) e aguardar.
- Não inventar estruturas de banco, nomes de colunas ou regras de negócio.

## 3) Boas práticas obrigatórias
### Contrato do dataset
- Declarar explicitamente:
  - objetivo da query;
  - fonte (tabelas); 
  - granularidade (grão);
  - coluna “data driver” para filtro por período;
  - parâmetros suportados (quando aplicável);
  - colunas de saída (apenas as necessárias).

### Performance e modelagem
- Reduzir volume cedo: filtrar período e selecionar poucas colunas nas primeiras etapas.
- Preferir filtros por intervalo sargável (>= e < com DATEADD no parâmetro).
- Evitar conversões/funções em colunas de filtro/join.
- Manter chaves e dimensões necessárias para o Power BI (setor, equipe, status, responsável, tipo, etc.).
- Preparar colunas derivadas no SQL quando fizer sentido para análise e consistência:
  - tempo de atendimento/decorrido;
  - flags de atraso;
  - status de SLA (no prazo/fora do prazo/em andamento).

### Clareza
- Evitar `SELECT *`.
- Usar aliases claros e consistentes.
- Estruturar em CTEs por intenção (ex.: `base`, `normalizado`, `agregado`).

## 4) Erros que devem ser evitados
- Criar query que não funciona como fonte para Power BI (ex.: múltiplos resultsets, colunas desnecessárias, grão inconsistente).
- Duplicar lógica conflitante (ex.: “atraso” calculado de um jeito no SQL e outro no DAX sem justificativa).
- Agregar cedo demais e “perder” o grão por demanda, impedindo drill-through.
- Usar filtro por data não sargável (ex.: `CAST(Data AS date)` na coluna filtrada).
- Misturar datas “driver” sem deixar explícito (abertura vs conclusão vs vencimento).

## 5) Padrões voltados para uso no Power BI
### Dataset recomendado (SLA)
- Preferência por base “1 linha por demanda” com colunas que suportem:
  - recortes por período (calendário);
  - recortes por setor/equipe/status;
  - KPIs de SLA (cumprimento/atraso/tempo médio).

### Convenções de nomes
- Arquivo: `sla__<objetivo>.sql` ou `produtividade__<objetivo>.sql`.
- Colunas derivadas (sugestão):
  - `TempoAtendimentoMinutos` / `TempoAtendimentoHoras`
  - `FlagAtraso`
  - `StatusSLA`

### Reuso no repositório
- Derivar de queries existentes:
  - Dataset base: [sql/queries/sla__dataset_demandas.sql](../sql/queries/sla__dataset_demandas.sql)
  - Exemplo agregado: [sql/queries/sla__tempo_medio_por_setor.sql](../sql/queries/sla__tempo_medio_por_setor.sql)

## 6) Exemplos de uso (sem SQL)
### Template de uso (copiar/colar)
Use este template para pedir criação/revisão de SQL com foco em Power BI:

- **Contexto**: (SLA ou produtividade) + qual decisão/monitoramento o dashboard precisa suportar.
- **Pergunta de negócio**: o que a query deve responder.
- **Fonte**: banco/schema/tabela(s) e colunas disponíveis.
- **Granularidade desejada**: (ex.: 1 linha por demanda; ou agregado por mês/setor).
- **Data driver do período**: abertura ou conclusão (escolher 1).
- **Definições**: o que é “concluído”, “em andamento”, “atraso” (por vencimento) e exceções.
- **Dimensões para recorte**: setor/equipe/status/tipo/responsável.
- **Saída esperada**: lista de colunas (dataset) e/ou métricas (agregado).
- **Restrições**: performance, janela padrão (ex.: últimos 90 dias), e se pode criar view.

Saída esperada da IA:
- Entregar a query (ou revisão) com header padrão, filtro por período sargável e colunas mínimas.
- Se faltar informação, fazer até 5 perguntas objetivas antes de escrever.

### Exemplo A — Criar dataset base de SLA
**Contexto**: SLA para acompanhamento operacional e priorização.

**Entrada mínima**:
- Fonte: tabela de demandas e colunas (Id, Setor, Equipe, Status, DataAbertura, DataConclusao, DataVencimento)
- Granularidade: 1 linha por demanda
- Data driver: DataAbertura
- Definição de atraso: vencida e ainda aberta, ou concluída após o vencimento

**Saída esperada**:
- Dataset pronto para Power BI com colunas derivadas (tempo de atendimento/decorrido, flags, status de SLA)
- Compatível com medidas DAX e drill-through

**Perguntas (se faltar info)**:
- Qual tabela/colunas reais? Existe “Equipe”? Quais valores de “Status” indicam concluído?

### Exemplo B — Revisar uma query existente
**Contexto**: query já em uso no Power BI com lentidão e divergência de métricas.

**Entrada mínima**:
- Query atual
- Data driver do relatório
- Regras de SLA/atraso adotadas no negócio

**Saída esperada**:
- Checklist de problemas encontrados (grão, filtros, colunas, sargabilidade)
- Versão revisada da query (mantendo o contrato) e observações de performance

### Exemplo C — Criar uma agregação derivada (sem perder o grão)
**Contexto**: necessidade de uma visão executiva por período, sem perder a trilha até o detalhe.

**Entrada mínima**:
- Dataset base (colunas e regras)
- Agrupamento desejado: mês x setor (e/ou equipe)

**Saída esperada**:
- Query agregada separada (ou variação documentada) com métricas de volume, atraso e tempo médio
- Recomendação de manter dataset detalhado para drill-through

## Checklist rápido (antes de publicar a query)
- O grão está explícito e correto?
- O filtro por período está claro e sargável?
- As colunas de SLA (atraso/status/tempo) estão coerentes com o negócio?
- As dimensões (setor/equipe/status) suportam os visuais do dashboard?
- O header do arquivo descreve objetivo, fonte, parâmetros e saída?
