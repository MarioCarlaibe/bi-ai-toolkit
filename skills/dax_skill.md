# Skill — DAX (SLA e Produtividade) para Power BI

## 1) Objetivo
Definir um padrão sênior para criação/revisão de **medidas DAX** focadas em SLA e produtividade, garantindo:
- consistência de definições (no prazo/fora do prazo/em andamento);
- performance (medidas enxutas, contexto bem controlado);
- reuso (biblioteca de KPIs coesa e facilmente copiável).

## 2) Como a IA deve se comportar
- Priorizar medidas (não colunas calculadas) para KPIs.
- Confirmar o modelo antes de escrever qualquer medida:
  - nome da tabela fato;
  - colunas de data (abertura, conclusão, vencimento);
  - existência/nome da tabela calendário e relação ativa;
  - dimensões (setor, equipe, status, responsável).
- Manter coerência com o dataset SQL e com o padrão do projeto:
  - Padrões SLA: [padroes_sla.md](../padroes_sla.md)
  - Medidas de referência: [dax/measures/sla__kpis.dax](../dax/measures/sla__kpis.dax)
- Se faltar informação, perguntar objetivamente e aguardar (máx. 5 perguntas).

## 3) Boas práticas obrigatórias
### Nomenclatura e organização
- Usar nomes claros e padronizados (ex.: prefixo de domínio “SLA | …”, “Produtividade | …”).
- Agrupar por “pastas de exibição” no Power BI quando aplicável (ex.: SLA, Produtividade, Qualidade).

### Performance
- Preferir agregações simples quando possível; usar iteradores somente quando necessário.
- Usar variáveis para evitar repetição e melhorar legibilidade.
- Usar `DIVIDE()` para percentuais e razões.
- Controlar filtros com clareza (respeitar/ignorar filtros conscientemente).

### Definições consistentes
- Definir “atraso” e “cumprimento de SLA” de forma objetiva:
  - atraso via vencimento (DataVencimento) e conclusão;
  - andamento quando DataConclusao estiver em branco.
- Garantir que KPIs funcionem com filtro por período (tabela calendário) e por setor/equipe.

## 4) Erros que devem ser evitados
- Misturar regras conflitantes (ex.: atraso por “tempo > meta” em uma medida e por vencimento em outra, sem deixar claro).
- Criar medida que só funciona em um visual específico (contexto frágil).
- Ignorar relacionamento de datas (ex.: usar DataAbertura quando o relatório está filtrando por DataConclusao sem intenção).
- Retornar 0 quando o correto seria BLANK (ou vice-versa) sem especificar a intenção.
- Fazer “otimização” que prejudica clareza e manutenção sem ganho real.

## 5) Padrões voltados para uso no Power BI
### Conjunto mínimo recomendado (SLA)
Uma base de KPIs reutilizável costuma incluir:
- total de demandas;
- demandas concluídas;
- demandas atrasadas;
- taxa de atraso (%);
- tempo médio de atendimento (horas/dias);
- % dentro do SLA (se existir regra/meta formal).

### Interação com dataset SQL
- Se o SQL já entrega flags (ex.: `FlagAtraso`, `StatusSLA`, `TempoAtendimentoMinutos`), preferir consumir essas colunas para reduzir complexidade e risco de divergência.

### Referências do repositório
- Medidas prontas: [dax/measures/sla__kpis.dax](../dax/measures/sla__kpis.dax)
- Dataset base para suporte às medidas: [sql/queries/sla__dataset_demandas.sql](../sql/queries/sla__dataset_demandas.sql)

## 6) Exemplos de uso (sem DAX)
### Template de uso (copiar/colar)
Use este template para pedir criação/revisão de medidas DAX com foco em SLA/produtividade:

- **Contexto**: (SLA ou produtividade) + qual decisão o KPI suportará.
- **Objetivo da medida**: o que calcular e unidade (%, horas, dias, qtd).
- **Definições**: concluído, em andamento, atraso (por vencimento) e exceções.
- **Modelo**:
  - tabela fato e colunas (datas, status, setor/equipe, etc.)
  - tabela calendário (nome, coluna de data) e qual data driver usar
- **Comportamento esperado**: BLANK vs 0; respeitar/ignorar filtros.
- **Validação**: como conferir resultado (amostra/SQL/KPI existente).

Saída esperada da IA:
- Entregar a medida com nome padronizado, `DIVIDE()` quando necessário, e contexto de filtro explícito.
- Se faltar informação, fazer até 5 perguntas objetivas antes de escrever.

### Exemplo A — Criar KPI de “% SLA cumprido”
**Contexto**: KPI de governança para acompanhar cumprimento de SLA.

**Entrada mínima**:
- Regra: concluída até o vencimento conta como “dentro”
- Colunas: DataVencimento e DataConclusao (e status de concluído, se existir)
- Filtros: respeitar período, setor e equipe

**Saída esperada**:
- Medida percentual estável para cards e séries temporais
- Comportamento definido quando não houver demandas (BLANK vs 0)

### Exemplo B — Ajustar medida para performance
**Contexto**: relatório lento em quebras por mês e setor.

**Entrada mínima**:
- Medida atual
- Visual principal onde está lenta (ex.: matriz por mês x setor)
- Cardinalidade aproximada (qtd de demandas)

**Saída esperada**:
- Versão otimizada (menos iteração, menos repetição, filtros explícitos)
- Observações do que mudou e por quê

### Exemplo C — Definir comportamento para BLANK/0
**Contexto**: evitar leituras enganosas em cards/segmentações com pouco volume.

**Entrada mínima**:
- Medida alvo (taxa de atraso)
- Regra desejada: retornar BLANK quando denominador for 0

**Saída esperada**:
- Medida com comportamento consistente em qualquer filtro/visual

## Checklist rápido (antes de publicar medidas)
- As definições (atraso, concluído, em andamento) estão consistentes?
- As medidas respeitam filtros de período e dimensões?
- As medidas evitam iterações desnecessárias?
- O retorno BLANK/0 está alinhado ao uso no dashboard?
