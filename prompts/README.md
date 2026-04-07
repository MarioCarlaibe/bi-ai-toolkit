# Prompts

Propósito: centralizar prompts reutilizáveis para tarefas de BI/Analytics (ex.: geração de SQL, criação de medidas DAX, revisão de modelagem, documentação).

Como usar:
- Armazene prompts completos (com contexto e instruções) diretamente em `prompts/`.
- Coloque trechos curtos e combináveis em `prompts/snippets/` (ex.: "regras de formatação", "checklist de qualidade").

Sugestão de padrão:
- Use Markdown (`.md`) para prompts longos.
- Nomes no formato: `tema__objetivo.md` (ex.: `sql__otimizar_consulta.md`).
