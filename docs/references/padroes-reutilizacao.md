# Padrões de reutilização (SQL / DAX / Prompts)

Objetivo: fazer o repositório funcionar como **biblioteca** (fácil de achar, copiar, adaptar e manter) para análises de SLA e produtividade em Power BI (SQL Server + DAX).

---

## 1) Princípios de biblioteca

1) **Descoberta > perfeição**: um bom nome + metadados no topo do arquivo valem mais do que código “perfeito” difícil de encontrar.
2) **Um arquivo = um caso de uso**: evite arquivos gigantes com “tudo de SLA”. Prefira componentes menores e reutilizáveis.
3) **Contrato claro**: cada item deve dizer: objetivo, granularidade, filtros esperados e colunas/medidas retornadas.
4) **Sem duplicação**: antes de criar algo novo, procure na biblioteca e derive de um existente.

---

## 2) Convenção de nomeação (recomendada)

Use nomes em minúsculo, sem acentos, com `__` para separar domínio e objetivo.

### Domínios sugeridos
- `sla`
- `produtividade`
- `backlog`
- `volume`
- `qualidade`

### Exemplos (arquivo)
- SQL: `sla__tempo_medio_por_setor.sql`
- SQL: `sla__dataset_demandas.sql`
- SQL: `sla__taxa_atraso_por_mes.sql`
- DAX: `sla__kpis.dax` (arquivo com conjunto pequeno e coeso de medidas)
- Prompt: `sql__gerar_query_powerbi.txt`

---

## 3) Padrão de “header” (metadados) por arquivo

### 3.1) SQL (T-SQL)

No topo de cada `.sql`, use um cabeçalho padrão:

- Objetivo
- Fonte (tabelas principais)
- Granularidade (grão)
- Coluna de data padrão (abertura/conclusão/referência)
- Parâmetros suportados (ex.: `@DataInicio`, `@DataFim`)
- Saída (colunas retornadas)
- Observações de performance (ex.: índice esperado, sargabilidade, filtros aplicados cedo)

Regras práticas:
- Sempre preferir filtro por intervalo sargável:
  - `Data >= @DataInicio AND Data < DATEADD(DAY, 1, @DataFim)`
- Evitar `SELECT *`.
- CTEs: use quando ajudar leitura e reuso; nomeie CTEs por intenção (`base`, `normalizado`, `agregado`).

### 3.2) DAX (Medidas)

Para medidas, o “header” pode ficar no arquivo `.dax` como separadores de seção (texto simples).

Regras práticas:
- Nome de medida com prefixo de domínio para facilitar busca:
  - `SLA | Tempo Médio de Atendimento (h)`
  - `SLA | Taxa de Atraso`
  - `SLA | Total de Demandas`
- Use `VAR` para cálculos intermediários.
- Use `DIVIDE()` sempre que houver divisão.
- Evite colunas calculadas quando o objetivo é KPI (prefira medida).

Dica de modelagem (Power BI):
- Centralize medidas em uma tabela “Medidas” (ex.: tabela desconectada chamada `Medidas`), e organize por pastas de exibição (Display folder) no Power BI com o mesmo prefixo (`SLA`, `Produtividade`).

### 3.3) Prompts

Padrão de prompts:
- **Começo**: função do assistente + contexto (Power BI + SQL Server + DAX + foco SLA/produtividade).
- **Coleta**: perguntas objetivas obrigatórias (contexto, objetivo, modelo, filtros).
- **Regras**: boas práticas (clareza, performance, reuso).
- **Contrato de saída**: “retorne apenas X” (SQL puro / DAX puro / análise estruturada).

Dica:
- Mantenha prompts “genéricos” em `prompts/` e regras curtas em `prompts/snippets/` para compor.

---

## 4) Organização por pastas (sem quebrar o que já existe)

### SQL
- Guardar queries “de biblioteca” em `sql/queries/`.
- Manter `sql/` para índices/READMEs e poucos arquivos âncora.

### DAX
- Guardar conjuntos de medidas em `dax/measures/` (um domínio por arquivo quando fizer sentido).
- Usar `dax/` para README e arquivos agregadores (opcional).

### Prompts
- `prompts/`: templates completos (SQL, DAX, análise).
- `prompts/snippets/`: regras e checklists curtos e reutilizáveis.

---

## 5) Sugestões para padronizar o que já existe

- Mover itens “de biblioteca” para as subpastas dedicadas e manter nomes descritivos (ex.: `sql/queries/…`, `dax/measures/…`).
- Padronizar prefixos de domínio (ex.: `SLA | …`) para medidas e títulos.
- Sempre documentar (no header) a coluna de data padrão e a granularidade.
