# Skill — Dashboard (SLA e Produtividade) no Power BI

## 1) Objetivo
Padronizar o desenho e a validação de dashboards de SLA e produtividade no Power BI, garantindo:
- narrativa clara (visão geral → diagnóstico → detalhe);
- consistência de métricas e definições;
- performance (modelagem e visuais eficientes);
- reutilização (layout/checklist replicável por área/time).

## 2) Como a IA deve se comportar
- Pensar como “dono do produto”: focar perguntas de negócio e decisões que o dashboard habilita.
- Usar o template do repositório como base e não reinventar estrutura sem motivo:
  - Template de SLA: [templates/dashboard.md](../templates/dashboard.md)
- Confirmar:
  - qual é a data driver padrão do relatório;
  - quais slicers entram na página principal vs detalhe;
  - quais KPIs são “essenciais” (4–6) e quais são opcionais.
- Evitar sugerir excesso de visuais/filtros; priorizar o mínimo que responde às perguntas.

## 3) Boas práticas obrigatórias
### Estrutura e UX
- Página 1 (Visão Geral): KPIs + tendência + ranking de gargalos + resumo por setor.
- Página 2 (Detalhe): tabela de demandas + drill-through + filtros avançados.
- Ordenar rankings do pior para o melhor quando o objetivo for priorização.

### Clareza de definição
- Títulos explícitos (ex.: “% dentro do SLA por Setor (pior primeiro)”).
- Definições documentadas (o que é atraso, dentro do SLA, em andamento).

### Performance no Power BI
- Preferir medidas (DAX) a colunas calculadas para KPIs.
- Evitar visuais com cardinalidade alta sem necessidade.
- Garantir que o dataset e a tabela calendário suportem o recorte por período.

## 4) Erros que devem ser evitados
- Encher a página principal de slicers/visuais e perder foco.
- Misturar datas sem sinalizar (ex.: analisar por abertura e concluir pelo filtro de conclusão).
- Usar cores/indicadores sem legenda e sem regra de negócio clara.
- Exibir % ou médias sem contexto de volume.
- Criar visuais “bonitos” que não respondem perguntas do objetivo.

## 5) Padrões voltados para uso no Power BI
### KPIs essenciais (SLA)
- % dentro do SLA ou taxa de atraso
- tempo médio de atendimento (h/dias)
- total de demandas
- demandas atrasadas (qtd)
- taxa de atraso (%)

### Visuais recomendados
- tendência: % SLA e volume por período (linha/colunas)
- ranking: % SLA por setor/equipe (pior → melhor)
- risco: atrasadas por setor/status
- detalhe: tabela no grão por demanda

### Slicers recomendados
- período
- setor/equipe
- status
- (opcional) tipo/categoria, prioridade, responsável

## 6) Exemplos de uso (sem configuração/código)
### Template de uso (copiar/colar)
Use este template para pedir desenho/revisão de dashboard no Power BI:

- **Tema**: SLA ou produtividade
- **Público-alvo**: operação, coordenação, diretoria (define nível de detalhe)
- **Objetivo**: quais decisões o dashboard deve suportar
- **Data driver**: qual data guia o período (abertura ou conclusão)
- **Dimensões**: setor/equipe/status (e tipo/responsável se existir)
- **KPIs essenciais**: lista (máx. 6)
- **Restrições**: janela padrão (ex.: 90 dias), performance, necessidade de drill-through
- **Saída esperada**: páginas, visuais, slicers e checklist de validação

Saída esperada da IA:
- Propor uma estrutura mínima (Visão Geral + Detalhe), com títulos explícitos, ordenação do pior→melhor quando aplicável e checklist antes de publicar.

### Exemplo A — Montar dashboard de SLA do zero
**Contexto**: dashboard de SLA para acompanhamento e priorização.

**Entrada mínima**:
- KPIs essenciais desejados (ex.: % SLA/taxa de atraso, tempo médio, volume, backlog)
- Dimensões de recorte (setor/equipe/status)

**Saída esperada**:
- Proposta de páginas (Visão Geral e Detalhe)
- Lista mínima de visuais e slicers por página
- Ordem e critérios de leitura (pior→melhor, evidências e contexto de volume)

### Exemplo B — Revisar dashboard existente
**Contexto**: dashboard existente com risco de excesso de informação.

**Entrada mínima**:
- Prints ou descrição da página principal e página de detalhe
- Lista de KPIs e slicers atuais

**Saída esperada**:
- Checklist de problemas (foco, consistência, ranking, contexto de volume)
- Recomendações objetivas do que remover, mover para detalhe e padronizar

### Exemplo C — Adaptar para produtividade
**Contexto**: ampliar o uso do dashboard para produtividade.

**Entrada mínima**:
- Definição de produtividade (ex.: concluídas/dia, throughput por equipe)
- Recortes (setor/equipe/status)

**Saída esperada**:
- Conjunto mínimo de KPIs e visuais que respondem “quanto”, “onde” e “por quê”
- Como manter consistência com a página de SLA (sem duplicar métricas conflitantes)

## Checklist de publicação
- As definições (SLA/atraso/andamento) estão documentadas e consistentes?
- Há páginas separadas para visão geral e detalhe?
- Rankings priorizam o pior primeiro quando o objetivo é ação?
- Existe contexto de volume para interpretar percentuais e médias?
- O período padrão evita excesso de dados e melhora usabilidade?
