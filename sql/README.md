# SQL

Propósito: guardar queries SQL reutilizáveis (extração, validação, auditoria, performance) com rastreabilidade.

Organização:
- `sql/queries/`: queries prontas para execução (SELECT/CTEs etc.).

Sugestão de padrão:
- Um arquivo por caso de uso.
- Inclua no topo: objetivo, fonte(s), parâmetros esperados e observações de performance.
- Extensão: `.sql`.
