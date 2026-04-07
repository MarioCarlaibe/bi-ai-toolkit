# Como aplicar esta skill

Sugestão de aplicação rápida (SLA):

1) Comece pelo dataset SQL: derive de um arquivo existente em `sql/queries/` e garanta filtro por período.
2) Crie/atualize medidas em `dax/measures/` seguindo a convenção `SLA | ...`.
3) Adicione pelo menos 2 alertas e 1 medida de texto (Smart Narrative).
4) Use o template em `templates/dashboard.md` para montar a página de Visão Geral + Detalhe.

Dica: mantenha limites (ex.: taxa de atraso alta) como VARs ajustáveis nas medidas de alerta.
