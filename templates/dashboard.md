# Template de Dashboard (Power BI) — SLA

Guia reutilizável para estruturar um dashboard focado em SLA (tempo de atendimento), com clareza, performance e foco em produtividade.

---

## 1) Objetivo do dashboard
Responder rapidamente:
- Como está o SLA no período (nível e tendência)?
- Onde estão os maiores gargalos (setor/equipe/status)?
- O que está atrasando (backlog e vencidos)?
- O volume mudou e impactou o SLA?

---

## 2) KPIs principais (cards)
Recomendação: manter de 4 a 6 KPIs no topo, com variação vs período anterior quando possível.

KPIs essenciais:
- **% Dentro do SLA**
- **Tempo Médio de Atendimento (h ou dias)**
- **Total de Demandas**
- **Demandas Atrasadas (qtd)**
- **Taxa de Atraso (%)**

KPIs opcionais (usar apenas se existir dado confiável):
- **Backlog Atual (qtd em aberto)**
- **Tempo Médio em Aberto (h/dias)** (para itens não concluídos)

Notas de definição (padronize no projeto):
- “Dentro do SLA” deve ter uma regra objetiva (por exemplo: `TempoAtendimento <= MetaSLA`).
- “Atrasada” deve considerar vencimento e conclusão (ex.: vencida e ainda aberta, ou concluída após o vencimento).

---

## 3) Tipos de gráficos ideais
### A) Tendência no tempo
Objetivo: ver evolução e detectar mudança de patamar.
- **Linha**: % Dentro do SLA por dia/semana/mês
- **Linha**: Tempo Médio de Atendimento (h/dias) por período
- **Colunas** (ou área): Total de Demandas por período (para contextualizar variação de volume)

Sugestão: use gráfico combinado (colunas = volume, linha = % SLA) quando fizer sentido.

### B) Quebra por setor/equipe
Objetivo: localizar onde o SLA piora.
- **Barras horizontais**: % Dentro do SLA por Setor (ordenado do pior para o melhor)
- **Barras horizontais**: Tempo Médio de Atendimento por Setor
- **Barras empilhadas**: Demandas por Status (em aberto, concluído, etc.) por Setor

### C) Atrasos / backlog
Objetivo: entender risco e acúmulo.
- **Barras**: Demandas Atrasadas por Setor
- **Heatmap/Matriz**: Setor x Status com contagem (para ver concentração)

### D) Distribuição (quando houver volume suficiente)
Objetivo: separar “média ruim” de “cauda longa”.
- **Histograma**: distribuição do Tempo de Atendimento
- **Boxplot** (se disponível via visual): distribuição por Setor

---

## 4) Organização visual (layout recomendado)
Estrutura sugerida (uma página principal + uma de detalhe):

### Página 1 — Visão Geral
1) **Topo (cards)**: KPIs essenciais
2) **Linha 1 (tendência)**: % Dentro do SLA + Volume (ou duas linhas separadas)
3) **Linha 2 (gargalos)**: ranking por Setor (pior → melhor) + atrasadas por setor
4) **Rodapé (tabela/matriz)**: tabela resumida por Setor com:
   - Total
   - % dentro do SLA
   - tempo médio
   - atrasadas

### Página 2 — Detalhamento
- Tabela detalhada de demandas (com colunas-chave e drillthrough)
- Segmentação por status/prioridade/canal/responsável

Boas práticas de leitura:
- Priorize ordem “o que aconteceu → onde → por quê”.
- Destaque o problema primeiro (pior setor no topo, ordenação descrescente).
- Use títulos explícitos (ex.: “% dentro do SLA por Setor (pior primeiro)”).

---

## 5) Sugestões de filtros (slicers)
Recomendados (quase sempre):
- **Período** (data de abertura ou data de conclusão — escolha 1 como padrão e deixe claro)
- **Setor / Equipe**
- **Status** (aberto, concluído, etc.)

Dependendo do processo:
- **Prioridade**
- **Canal**
- **Responsável**
- **Tipo/Categoria**
- **Indicador de SLA** (Dentro/Fora do SLA)

Padrões:
- Defina um período padrão (ex.: últimos 90 dias) para melhorar performance e usabilidade.
- Evite muitos slicers na página principal; mova filtros avançados para a página de detalhe.

---

## 6) Checklist rápido (antes de publicar)
- Definições de SLA/atraso estão consistentes e documentadas.
- Principais KPIs batem com amostras/validações no SQL.
- Rankings estão ordenados do pior para o melhor.
- O período padrão é razoável (não explode volume no Power BI).
- As páginas respondem às perguntas do objetivo (Seção 1).
