# Checklist — Kit de análise (SQL + DAX + Insights)

Use este checklist ao aplicar o padrão em um novo dashboard.

## Dataset (SQL)
- [ ] A query tem objetivo, grão e data driver definidos no header.
- [ ] Filtro por período é sargável e parametrizado (DataInicio/DataFim quando aplicável).
- [ ] Não usa `SELECT *` e retorna só colunas necessárias.
- [ ] O cálculo de tempo (SLA) valida datas (conclusão >= abertura).
- [ ] Dimensões para análise (Equipe/Setor/Status) estão disponíveis.

## Medidas (DAX)
- [ ] Medidas base existem (Total, Concluídas, Atrasadas, Tempo Médio).
- [ ] Divisões usam `DIVIDE`.
- [ ] Time intelligence respeita a tabela calendário (se houver) e a data driver escolhida.
- [ ] Medidas são consistentes com a query (mesmos conceitos de atraso/conclusão).

## Insights automáticos
- [ ] Existem alertas (0/1) com limites claros e fáceis de ajustar.
- [ ] Existe uma medida de texto curta para Smart Narrative.
- [ ] O texto diferencia fato (métricas) de ação (recomendação).

## Dashboard
- [ ] Cards de KPI no topo e tendência por período visível.
- [ ] Ranking por Equipe/Setor ordenado do pior para o melhor.
- [ ] Filtros principais: período, equipe/setor, status.
