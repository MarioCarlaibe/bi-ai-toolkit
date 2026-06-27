# Skill — HTML Content Visual no Power BI

## 0) Quando usar esta skill
Use esta skill quando o usuário pedir:
- componentes visuais customizados no Power BI que os nativos não suportam (cards com cor condicional, barras de progresso, semáforos, gauges);
- medidas DAX que geram HTML para o visual **HTML Content**;
- adaptar ou revisar uma medida DAX existente que retorna string HTML.

**Não usar** quando o Power BI nativo resolver: indicadores KPI, barras de dados em tabelas e gráficos de barras comuns não precisam de HTML.

## 1) Objetivo
Padronizar a geração de HTML compatível com o visual **HTML Content** do Power BI, garantindo:
- componentes visuais ricos (cards, tabelas, barras de progresso, semáforos, gauges em SVG) que vão além dos nativos;
- HTML autossuficiente (sem dependências externas), seguro e performático;
- medidas DAX que montam strings HTML limpas e reutilizáveis;
- consistência visual com o tema do relatório (cores, tipografia, espaçamento).

## 2) Como a IA deve se comportar
- Atuar como especialista em componentes visuais para Power BI: priorizar o que o visual precisa responder antes de escrever uma linha de HTML.
- Confirmar antes de gerar:
  - qual métrica ou conjunto de métricas será exibido;
  - qual o tipo de componente esperado (card KPI, tabela customizada, barra de progresso, semáforo, etc.);
  - quais cores/fonte/tamanho seguir (ou se há um padrão visual do relatório);
  - se há necessidade de lógica condicional (ex.: verde/amarelo/vermelho por faixa de valor).
- Gerar sempre o HTML como **medida DAX** que retorna string — nunca como arquivo separado, a não ser que o usuário peça expressamente para testar o HTML isolado.
- Manter a medida legível: usar variáveis DAX (`VAR`) para cada trecho do HTML e montar ao final com `RETURN`.
- Perguntar no máximo 5 questões objetivas quando faltar informação.

## 3) Boas práticas obrigatórias
### Estrutura do HTML
- Todo HTML deve ser **autossuficiente**: CSS inline ou em bloco `<style>` interno; sem links para CDN externo.
- Usar `<div>` como container raiz com `font-family` e `font-size` explícitos para evitar herança indesejada do Power BI.
- Preferir SVG para gráficos simples (barras, arcos, gauges): mais leve, escalável e sem dependência de biblioteca.
- Evitar `<script>` — o visual filtra JavaScript; lógica condicional deve estar no DAX, não no HTML.

### Geração da string no DAX
- Usar `VAR` para cada bloco semântico (cabeçalho, corpo, rodapé, estilo) e concatenar com `&`.
- Formatar números antes de inserir no HTML: `FORMAT([Medida], "0.0%")` ou `FORMAT([Medida], "#,##0")`.
- Usar `IF`, `SWITCH` e `VAR cor =` no DAX para definir cor/ícone por faixa — nunca colocar lógica condicional dentro da string HTML.
- Retornar `BLANK()` quando não houver dado para não exibir HTML vazio/quebrado no visual.

### Performance
- Manter o HTML gerado simples: quanto mais longo o HTML, mais lenta a renderização no visual.
- Evitar `CONCATENATEX` sobre tabelas grandes sem antes filtrar ou agregar no DAX.
- Preferir medidas já calculadas como variável no início da medida, não recalcular dentro do HTML.

### Segurança e compatibilidade
- Não inserir valores brutos de texto livre do usuário diretamente no HTML sem sanitização (`SUBSTITUTE` para `<`, `>`, `"`).
- Não usar propriedades CSS modernas sem fallback (ex.: `grid`, `flex` com prefixo `-webkit-` quando necessário).
- Testar com dados nulos/vazios: a medida deve degradar graciosamente.
- Contraste mínimo: garantir razão de contraste ≥ 4,5:1 entre texto e fundo (ex.: texto branco `#fff` em fundo `#2ECC71` verde cumpre; texto cinza claro em fundo branco não cumpre).

## 4) Erros que devem ser evitados
- Usar `<script>` ou `onclick` — o visual bloqueia JavaScript.
- Referenciar fontes, imagens ou estilos externos (CDN, URL) — bloqueado por segurança do Power BI.
- Montar HTML com concatenação direta de medidas sem `FORMAT` — gera números com muitas casas decimais ou formato errado.
- Retornar string vazia `""` em vez de `BLANK()` quando não há dado — o visual pode renderizar caixa em branco sem aviso.
- Colocar lógica de cor/alerta dentro da string HTML como texto literal — dificulta manutenção; lógica deve estar no DAX.
- Gerar HTML muito longo via `CONCATENATEX` linha a linha sobre tabelas de alta cardinalidade — causa lentidão.

## 5) Padrões voltados para uso no Power BI
### Tipos de componente recomendados
- **Card KPI customizado**: valor principal grande, rótulo, variação com ícone seta/cor, fundo condicional.
- **Barra de progresso**: retângulo SVG com preenchimento proporcional ao valor; rótulo de % ao lado.
- **Semáforo / Status**: círculo SVG colorido por faixa (verde/amarelo/vermelho) + texto descritivo.
- **Mini tabela HTML**: cabeçalho fixo, linhas zebradas, coluna de status condicional — para até ~20 linhas.
- **Gauge / Arco SVG**: arco de círculo parcial indicando posição do valor entre mínimo e máximo.

### Paleta de status recomendada (padrão do toolkit)
- Verde (dentro do SLA / OK): `#2ECC71` ou `#27AE60`
- Amarelo (atenção / próximo do limite): `#F39C12` ou `#F1C40F`
- Vermelho (atrasado / fora do SLA): `#E74C3C` ou `#C0392B`
- Neutro / sem dado: `#BDC3C7`

### Estrutura mínima de medida DAX gerando HTML
```
HTML Card =
VAR _valor   = [% SLA Cumprido]
VAR _cor     = IF(_valor >= 0.9, "#2ECC71", IF(_valor >= 0.7, "#F39C12", "#E74C3C"))
VAR _texto   = FORMAT(_valor, "0.0%")
VAR _retorno =
    IF(
        ISBLANK(_valor),
        BLANK(),
        "<div style='font-family:Segoe UI,sans-serif;padding:12px;background:" & _cor & ";border-radius:8px;color:#fff;text-align:center'>"
            & "<div style='font-size:32px;font-weight:700'>" & _texto & "</div>"
            & "<div style='font-size:13px;margin-top:4px'>% SLA Cumprido</div>"
        & "</div>"
    )
RETURN _retorno
```

### Estrutura mínima de barra de progresso SVG
```
HTML Barra =
VAR _perc  = [% SLA Cumprido]
VAR _w     = FORMAT(ROUND(_perc * 200, 0), "0")   -- largura do fill em px (max 200)
VAR _cor   = IF(_perc >= 0.9, "#2ECC71", IF(_perc >= 0.7, "#F39C12", "#E74C3C"))
VAR _label = FORMAT(_perc, "0.0%")
RETURN
    IF(
        ISBLANK(_perc), BLANK(),
        "<div style='font-family:Segoe UI,sans-serif;padding:10px'>"
        & "<svg width='220' height='28'>"
        & "<rect x='0' y='6' width='200' height='16' rx='8' fill='#ECF0F1'/>"
        & "<rect x='0' y='6' width='" & _w & "' height='16' rx='8' fill='" & _cor & "'/>"
        & "<text x='208' y='18' font-size='12' fill='#333'>" & _label & "</text>"
        & "</svg></div>"
    )
```

### Estrutura mínima de gauge / arco SVG
```
HTML Gauge =
VAR _perc   = [% SLA Cumprido]                        -- valor entre 0 e 1
VAR _cor    = IF(_perc >= 0.9, "#2ECC71", IF(_perc >= 0.7, "#F39C12", "#E74C3C"))
VAR _label  = FORMAT(_perc, "0.0%")
-- Arco SVG: raio 50, centro (60,60), ângulo de -180° a 0° = semicírculo
-- Ângulo do fill: de -180° até (-180° + 180°*_perc)
VAR _angRad = (_perc * 3.14159)                        -- radianos do fill
VAR _x      = FORMAT(60 - 50 * COS(_angRad), "0.00")  -- ponto final X do arco
VAR _y      = FORMAT(60 - 50 * SIN(_angRad), "0.00")  -- ponto final Y do arco
VAR _large  = IF(_perc > 0.5, "1", "0")               -- large-arc-flag do SVG
RETURN
    IF(
        ISBLANK(_perc), BLANK(),
        "<div style='font-family:Segoe UI,sans-serif;text-align:center;padding:8px'>"
        & "<svg width='120' height='70' viewBox='0 0 120 70'>"
        & "<path d='M10,60 A50,50 0 0,1 110,60' fill='none' stroke='#ECF0F1' stroke-width='12'/>"
        & "<path d='M10,60 A50,50 0 " & _large & ",1 " & _x & "," & _y & "' fill='none' stroke='" & _cor & "' stroke-width='12'/>"
        & "<text x='60' y='58' text-anchor='middle' font-size='16' font-weight='700' fill='" & _cor & "'>" & _label & "</text>"
        & "</svg>"
        & "<div style='font-size:11px;color:#666;margin-top:2px'>% SLA Cumprido</div>"
        & "</div>"
    )
```

> **Nota**: DAX não tem funções trigonométricas nativas. Para gauges com cálculo preciso de arco, pré-calcular os pontos no SQL ou usar aproximações lineares simples (largura proporcional) em vez de arco real.

## 6) Exemplos de uso
### Template de uso (copiar/colar)
Use este template para solicitar geração de HTML Content no Power BI:

- **Componente**: card KPI / barra de progresso / semáforo / mini tabela / gauge
- **Métrica(s)**: qual(is) medida(s) DAX serão exibidas
- **Lógica condicional**: faixas de cor (ex.: verde ≥ 90 %, amarelo ≥ 70 %, vermelho abaixo)
- **Estilo**: cores de fundo, cor do texto, tamanho de fonte, borda arredondada (sim/não)
- **Contexto de filtro**: o visual está em contexto de linha de tabela, matriz ou página inteira
- **Saída esperada**: medida DAX completa gerando a string HTML

### Exemplo A — Card KPI com cor condicional
**Contexto**: card de "% SLA Cumprido" com fundo colorido por faixa.

**Entrada mínima**:
- Medida: `[% SLA Cumprido]`
- Faixas: verde ≥ 90 %, amarelo ≥ 70 %, vermelho abaixo

**Saída esperada**:
- Medida DAX com variáveis `_valor`, `_cor`, `_texto`
- HTML com `<div>` de fundo colorido, valor em destaque e rótulo abaixo
- `RETURN BLANK()` quando a medida for nula

### Exemplo B — Barra de progresso em SVG por linha de tabela
**Contexto**: coluna de progresso dentro de uma tabela do Power BI, exibindo barra SVG por setor.

**Entrada mínima**:
- Medida: `[% Concluído por Setor]`
- Largura máxima desejada da barra (ex.: 150 px)

**Saída esperada**:
- Medida DAX que calcula largura do fill proporcional ao valor
- SVG com retângulo de fundo cinza e fill colorido condicional
- Rótulo de porcentagem ao lado da barra

**Perguntas (se faltar info)**:
- Qual é a largura do campo no visual para dimensionar a barra SVG?
- A barra precisa de rótulo de valor ou apenas a cor já basta?

### Exemplo C — Semáforo de status por demanda
**Contexto**: coluna de status em tabela com ícone de círculo colorido (verde/amarelo/vermelho) + texto.

**Entrada mínima**:
- Coluna ou medida de status (ex.: `[Status SLA]` retornando "No Prazo", "Atenção", "Atrasado")
- Mapeamento texto → cor

**Saída esperada**:
- Medida DAX com `SWITCH([Status SLA], ...)` para definir cor e rótulo
- HTML com círculo SVG colorido + texto ao lado em `<span>`
- Fallback neutro (`#BDC3C7`) quando o status for desconhecido ou nulo

## Checklist de publicação
- O HTML é autossuficiente (sem CDN, sem URL externa, sem `<script>`)?
- Todos os valores numéricos passam por `FORMAT` antes de entrar na string?
- A medida retorna `BLANK()` quando não há dado (não retorna string vazia)?
- A lógica condicional (cor, ícone, texto) está no DAX, não hardcoded no HTML?
- O componente foi testado com filtro zerado / sem seleção para garantir degradação segura?
- O HTML renderiza corretamente no tamanho do campo previsto no layout do relatório?
