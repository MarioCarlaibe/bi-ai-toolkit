# 📊 Padrões de Análise - SLA e Produtividade

## 🎯 Objetivo
Definir padrões reutilizáveis para análise de SLA dentro do Power BI, garantindo consistência, clareza e performance.

---

## 📌 Definição de SLA

SLA (Service Level Agreement) representa o tempo esperado para conclusão de uma demanda.

### Tipos de SLA:

- SLA no prazo → finalizado dentro do tempo esperado
- SLA fora do prazo → ultrapassou o tempo definido
- SLA em andamento → ainda não finalizado

---

## 🧩 Estrutura padrão de dados

Toda análise deve considerar:

- ID da demanda
- Data de abertura
- Data de finalização
- Status
- Responsável
- Tipo de demanda
- Tempo decorrido

---

## 🧠 Lógica padrão de cálculo

### Tempo de atendimento

- Se finalizado:
  → diferença entre data de abertura e finalização

- Se em aberto:
  → diferença entre data de abertura e data atual

---

## 📊 Métricas obrigatórias (DAX)

Sempre que analisar SLA, criar:

- Total de demandas
- Demandas no prazo
- Demandas fora do prazo
- % SLA cumprido
- Tempo médio de atendimento

---

## 📐 Padrões de medidas (DAX)

### % SLA Cumprido

- Sempre usar DIVIDE
- Evitar divisão direta

### Tempo médio

- Usar AVERAGE ou AVERAGEX
- Evitar colunas calculadas desnecessárias

---

## 🗄️ Padrões de SQL

- Sempre trazer dados já preparados para análise
- Criar colunas como:
  - tempo_atendimento
  - status_sla (no prazo / fora do prazo)

---

## 📈 Padrões de visualização (Power BI)

### Dashboard de SLA deve conter:

1. KPI principal:
   - % SLA cumprido

2. Gráficos:
   - Volume de demandas por período
   - SLA por equipe
   - SLA por tipo

3. Tabela detalhada:
   - Lista de demandas com status SLA

---

## 🚨 Alertas importantes

- Nunca calcular tudo no Power BI se puder vir pronto do SQL
- Evitar lógica duplicada (SQL + DAX)
- Sempre validar se o SLA está coerente com o negócio

---

## 🧠 Regras para IA (Copilot)

Ao gerar código ou sugestões:

- Priorizar reutilização
- Seguir esses padrões
- Nomear variáveis claramente
- Pensar em performance
- Focar em uso dentro do Power BI

---

## 🔁 Reutilização

Antes de criar qualquer nova análise:

1. Verificar se já existe algo similar
2. Adaptar ao invés de recriar
3. Manter consistência entre análises

---

## 🚀 Objetivo final

Criar análises de SLA:

- consistentes
- reutilizáveis
- performáticas
- fáceis de entender
- prontas para tomada de decisão