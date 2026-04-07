<!-- 
PROMPT INICIAL (usar sempre ao abrir o VS Code):

Considere o arquivo contexto.md deste projeto.

Estou desenvolvendo análises para Power BI utilizando SQL Server e DAX.
Use os padrões definidos no projeto, reutilize queries e medidas existentes,
e siga as boas práticas descritas neste arquivo.

Sempre priorize:
- clareza
- performance
- reutilização
- foco em análise de SLA e produtividade
-->

# 🧠 Contexto do Projeto - AI BI Toolkit

## 🎯 Objetivo
Este projeto tem como objetivo acelerar a criação de análises e dashboards no Power BI utilizando:
- SQL Server como fonte de dados
- Power BI como ferramenta de visualização
- DAX para métricas
- Padrões reutilizáveis (queries, medidas e templates)
- IA (Copilot) como assistente de desenvolvimento

---

## 🧩 Como a IA deve se comportar
Sempre considerar:

- Reutilizar padrões existentes antes de criar algo do zero
- Priorizar clareza e organização do código
- Explicar a lógica antes de sugerir código (quando solicitado)
- Gerar apenas código quando pedido explicitamente
- Seguir boas práticas de SQL e DAX
- Pensar sempre no uso final dentro do Power BI

---

## 📂 Estrutura do Projeto

- `/prompts` → prompts reutilizáveis para IA
- `/sql` → queries SQL organizadas por tema (ex: SLA, produtividade)
- `/dax` → medidas DAX reutilizáveis
- `/templates` → estruturas de dashboards Power BI
- `/contexto.md` → este arquivo (memória do projeto)

---

## 📊 Regras de SQL (foco em Power BI)

- Sempre usar alias claros
- Evitar SELECT *
- Priorizar performance
- Permitir filtros por data quando aplicável
- Usar agregações (SUM, AVG, COUNT)
- Pensar em queries que funcionem bem como fonte para dashboards

---

## 🧮 Regras de DAX (Power BI)

- Criar medidas reutilizáveis
- Usar nomes claros e padronizados
- Evitar cálculos desnecessários em colunas
- Priorizar medidas em vez de colunas calculadas
- Usar DIVIDE ao invés de divisão direta
- Pensar em performance e contexto de filtro

---

## 📈 Contexto de Negócio

As análises são focadas em:

- SLA (tempo de atendimento)
- Demandas atrasadas
- Produtividade por equipe/setor
- Volume de demandas ao longo do tempo

---

## 🧠 Padrões importantes

- Reutilizar arquivos como base (ex: `sql/queries/sla__tempo_medio_por_setor.sql`, `dax/measures/sla__kpis.dax`)
- Adaptar consultas existentes em vez de criar novas
- Manter consistência entre SQL e DAX
- Garantir que tudo seja utilizável no Power BI

---

## 💬 Como responder

Sempre que possível:

1. Entender o contexto do projeto
2. Reutilizar padrões existentes
3. Sugerir melhorias
4. Manter foco em análise de dados para Power BI

---

## 🚀 Objetivo final

Criar dashboards profissionais, organizados, performáticos e escaláveis no Power BI com alta produtividade usando IA.