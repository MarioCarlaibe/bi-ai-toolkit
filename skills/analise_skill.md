# Skill — Análise (SLA e Produtividade) para Power BI

## 1) Objetivo
Padronizar a **análise sênior** de SLA e produtividade (insights acionáveis) a partir de datasets/relatórios do Power BI, com foco em:
- leitura executiva (o que mudou, onde piorou, por quê);
- diagnóstico (sinais, evidências, hipóteses);
- priorização (P1/P2/P3) e recomendações mensuráveis.

## 2) Como a IA deve se comportar
- Separar claramente **fato (dado)** vs **hipótese (possível causa)**.
- Trabalhar sempre com:
  - período analisado e comparativo (período anterior, meta, baseline);
  - quebras principais (setor/equipe/status/tipo/responsável);
  - distribuição (média vs cauda/outliers) quando houver volume.
- Quando não houver números suficientes, solicitar os mínimos necessários e aguardar.
- Reutilizar padrões do repositório:
  - Padrões SLA: [padroes_sla.md](../padroes_sla.md)
  - Template de dashboard (estrutura de perguntas): [templates/dashboard.md](../templates/dashboard.md)
  - Prompt de análise (formato de saída): [prompts/analise.txt](../prompts/analise.txt)

## 3) Boas práticas obrigatórias
### Estrutura do raciocínio
- Começar por um resumo executivo (3–6 bullets) com:
  - direção (melhorou/piorou/estável);
  - magnitude (quando houver);
  - principais contribuintes (top 1–3 setores/equipes/status).

### Evidência e rastreabilidade
- Sempre ancorar insights em:
  - números/percentuais do período;
  - comparação (vs período anterior/meta);
  - recorte (setor/equipe/status).

### Qualidade e coerência
- Validar coerência de definições:
  - atraso baseado em vencimento (quando aplicável);
  - itens em andamento não entram em tempo de atendimento concluído.
- Indicar limitações de dados (nulos, datas inválidas, mudanças de processo).

### Recomendações orientadas a resultado
- Cada recomendação deve indicar:
  - ação sugerida;
  - impacto esperado;
  - métrica que deve melhorar (ex.: reduzir taxa de atraso, reduzir tempo médio, estabilizar backlog).

## 4) Erros que devem ser evitados
- “Afirmar causa” sem evidência (ex.: atribuir atraso a um time sem mostrar dados).
- Ignorar volume (ex.: concluir tendência com poucos casos).
- Usar somente média e esconder outliers (cauda longa).
- Misturar conceitos (tempo de atendimento de concluídas vs tempo decorrido de em andamento).
- Recomendações genéricas sem métrica-alvo.

## 5) Padrões voltados para uso no Power BI
### Recortes que devem existir (sempre que possível)
- período (com tabela calendário);
- setor e/ou equipe;
- status (aberto/concluído e variações);
- indicador de atraso (vencida ou concluída após vencimento);
- tipo/categoria (quando existir) para identificar causas estruturais.

### Leituras essenciais (SLA)
- % dentro do SLA / taxa de atraso
- tempo médio (e, se possível, mediana)
- volume por período (contexto)
- backlog atual (em aberto)

### Alinhamento com o dashboard
- Garantir que a análise “responda” às perguntas do template:
  - nível e tendência;
  - gargalos;
  - risco (atrasos/backlog);
  - efeito de volume.

## 6) Exemplos de uso (sem números inventados)
### Template de uso (copiar/colar)
Use este template para pedir análise sênior (insights) em SLA/produtividade:

- **Tema**: SLA ou produtividade
- **Objetivo**: quais decisões/ações a análise deve orientar
- **Período**: período analisado + comparativo (período anterior/meta/baseline)
- **Definições**: atraso (por vencimento), concluído, em andamento
- **Recortes obrigatórios**: setor/equipe/status (e tipo/responsável se existir)
- **Entradas** (um dos formatos):
  - tabela/print de KPIs por período
  - resumo numérico + ranking por setor/equipe
  - descrição do modelo + métricas disponíveis
- **Saída esperada**: resumo executivo + insights + alertas + recomendações P1/P2/P3

Saída esperada da IA:
- Separar fatos de hipóteses, ancorar tudo em evidência e listar “dados faltantes” quando necessário.

### Exemplo A — Relato executivo mensal
**Contexto**: prestação de contas mensal e priorização de ações.

**Entrada mínima**:
- KPIs do mês e do mês anterior (% SLA/taxa de atraso, tempo médio, volume)
- Ranking por setor/equipe (top/bottom)

**Saída esperada**:
- Resumo executivo (3–6 bullets)
- Top 3 pioras e top 3 melhoras com evidência
- Alertas e recomendações P1/P2/P3 com métrica-alvo

### Exemplo B — Diagnóstico de gargalo
**Contexto**: aumento percebido de tempo médio de atendimento.

**Entrada mínima**:
- Série temporal de tempo médio + volume
- Quebra por setor/equipe/status
- Indicador de distribuição (ex.: percentis, outliers ou contagem por faixas)

**Saída esperada**:
- Diagnóstico com 2–3 hipóteses (com evidências)
- Indicação do principal contribuinte e próximos cortes/validações

### Exemplo C — Plano de ação operacional
**Contexto**: backlog/atrasos em crescimento e necessidade de ação imediata.

**Entrada mínima**:
- Atrasadas por setor e por status
- Backlog atual e tendência
- Capacidade/volume concluído (se existir)

**Saída esperada**:
- Ações P1 (0–2 semanas), P2 (2–6 semanas), P3 (estruturais)
- KPIs que devem melhorar e como monitorar

## Checklist rápido (antes de enviar a análise)
- Há separação explícita entre fatos e hipóteses?
- Existe comparativo (vs período anterior/meta) quando aplicável?
- Os principais contribuintes (setor/equipe/status) estão destacados?
- As recomendações têm métrica-alvo e prioridade?
