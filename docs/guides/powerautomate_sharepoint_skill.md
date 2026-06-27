# Skill — Formulários SharePoint + Fluxos Power Automate

## 0) Quando usar esta skill
Use esta skill quando o usuário pedir:
- criar ou revisar formulários no SharePoint (listas, colunas, validações);
- montar fluxos no Power Automate com aprovação, notificação ou integração;
- escrever expressões e funções JSON/dinâmicas em fluxos Power Automate;
- integrar formulários e fluxos com Microsoft Teams e/ou Outlook;
- gerenciar ciclo de vida de demandas (abertura → aprovação → execução → encerramento).

**Não usar** para SQL, DAX ou dashboards Power BI — há skills específicas para isso.

---

## 1) Objetivo
Padronizar a criação de formulários no SharePoint e fluxos de automação no Power Automate, entregando:
- formulários funcionais com validação e ciclo de vida definido;
- fluxos robustos de aprovação (serial, paralela, condicional);
- integração real com Teams e Outlook (Adaptive Cards, e-mails HTML);
- expressões e funções JSON reutilizáveis e explicadas;
- estrutura de gestão de demandas operacional e auditável.

---

## 2) Como a IA deve se comportar
- Perguntar o contexto de negócio antes de propor qualquer estrutura: qual é o processo, quem aprova, quais SLAs existem.
- Propor a estrutura mínima que resolve o problema — não criar colunas, etapas ou conectores desnecessários.
- Escrever expressões completas e explicar cada função (parâmetros, tipos, valor retornado).
- Indicar limitações conhecidas do Power Automate (ex.: licença necessária, limite de aprovações, comportamento de timeout).
- Perguntar no máximo 5 questões objetivas quando faltar informação crítica.
- Nunca inventar nomes de campos, conectores ou permissões que não existam na plataforma.

---

## 3) Formulários no SharePoint

### 3.1) Estrutura de lista como backend de formulário
Uma lista do SharePoint é o banco de dados do formulário. Cada item = uma submissão.

**Colunas essenciais para gestão de demandas:**

| Nome interno (sem espaço) | Tipo | Descrição |
|---|---|---|
| `Title` | Linha de texto | Título / assunto da demanda |
| `Solicitante` | Pessoa/Grupo | Quem abriu a demanda |
| `DataAbertura` | Data e hora | Preenchimento automático via fluxo ou padrão |
| `DataPrazo` | Data e hora | Prazo esperado de resolução |
| `StatusDemanda` | Escolha | Pendente / Em análise / Aprovado / Reprovado / Concluído / Cancelado |
| `Prioridade` | Escolha | Baixa / Média / Alta / Crítica |
| `Descricao` | Várias linhas de texto (Rich Text) | Detalhamento da demanda |
| `Aprovador` | Pessoa/Grupo | Responsável pela aprovação |
| `DataAprovacao` | Data e hora | Preenchida pelo fluxo após decisão |
| `JustificativaAprovacao` | Várias linhas de texto | Comentário do aprovador |
| `ResultadoAprovacao` | Escolha | Aprovado / Reprovado / Pendente |
| `Responsavel` | Pessoa/Grupo | Executor da demanda após aprovação |
| `DataConclusao` | Data e hora | Preenchida ao encerrar |
| `ComentarioConclusao` | Várias linhas de texto | Observações ao concluir |
| `IDExterno` | Linha de texto | ID de sistema externo (se aplicável) |

### 3.2) Ocultar campos no formulário por modo (novo vs edição)

Para mostrar campos apenas na criação (ocultar na edição), usar fórmula condicional na coluna:

```
=if([$ID]>0,'false','true')
```
- ID > 0 → item já existe (modo edição) → oculta o campo
- ID = 0 → item novo → exibe o campo

Configuração: Editar coluna → **Opções avançadas** → **Fórmula condicional para mostrar/ocultar a coluna**.

### 3.3) Formatação de coluna — tooltip para campos longos

Para exibir o conteúdo completo de um campo ao passar o mouse (útil para Descrição em modo compacto):

**Tooltip nativo (texto puro):**
```json
{"$schema":"https://developer.microsoft.com/json-schemas/sp/v2/column-formatting.schema.json","elmType":"div","attributes":{"title":"@currentField"},"style":{"overflow":"hidden","text-overflow":"ellipsis","white-space":"nowrap","cursor":"default"},"txtContent":"@currentField"}
```

**Cartão flutuante com HTML renderizado** (para campos Rich Text com `<br>` e parágrafos):
```json
{"$schema":"https://developer.microsoft.com/json-schemas/sp/v2/column-formatting.schema.json","elmType":"div","style":{"overflow":"hidden","text-overflow":"ellipsis","white-space":"nowrap","cursor":"default"},"txtContent":"@currentField","customCardProps":{"formatter":{"elmType":"div","style":{"max-width":"420px","max-height":"300px","overflow-y":"auto","padding":"12px 16px","font-size":"13px","font-family":"Segoe UI, Arial, sans-serif","line-height":"1.6","color":"#333"},"innerHTML":"@currentField"},"openOnEvent":"hover","directionalHint":"bottomLeftEdge","isBeakVisible":true}}
```

Aplicar em: Configurações da coluna → **Formatar esta coluna** → **Formatação avançada**.

### 3.4) Configurações de coluna importantes
- **Colunas de status**: usar tipo "Escolha" com valores fixos — nunca "Linha de texto" livre para campos controlados por fluxo.
- **Colunas automáticas**: `DataAbertura`, `DataAprovacao`, `DataConclusao` devem ser preenchidas pelo fluxo, não pelo usuário. Configurar como somente leitura no formulário (via Power Apps ou regras de coluna).
- **Validações de coluna**: usar fórmulas de validação em colunas de data para evitar datas inválidas:
  ```
  =IF(DataPrazo < DataAbertura, FALSE, TRUE)
  ```
- **Valor padrão de status**: definir `StatusDemanda = "Pendente"` como padrão para novos itens.

### 3.3) Permissões da lista
- **Solicitantes**: permissão "Contribuir" — criam itens mas não editam status/aprovação.
- **Aprovadores**: permissão "Editar" — ou controle via fluxo (evita edição direta).
- **Gestores**: permissão "Controle total".
- Recomendado: usar **grupos do SharePoint** por papel (não permissões individuais).

### 3.4) Formulário customizado com Power Apps (opcional)
Quando o formulário nativo do SharePoint não for suficiente (campos condicionais, validações complexas, UX customizada):
1. Abrir a lista → **Integrar** → **Power Apps** → **Personalizar formulários**.
2. O formulário gerado automaticamente é um Canvas App vinculado à lista.
3. Para campos condicionais: usar propriedade `Visible` do controle com expressão:
   ```
   If(DataCardValue1.Selected.Value = "Alta", true, false)
   ```
4. Para validação antes de salvar: usar propriedade `OnSelect` do botão salvar com `If(IsBlank(campo), Notify("Campo obrigatório", NotificationType.Error), SubmitForm(Form1))`.

---

## 4) Fluxos no Power Automate

### 4.1) Gatilhos (Triggers) mais usados com SharePoint

| Trigger | Quando usar |
|---|---|
| `When an item is created` | Abertura de nova demanda |
| `When an item is created or modified` | Qualquer alteração (cuidado com loops) |
| `When an item is modified` | Atualização de status, aprovação |
| `For a selected item` | Ação manual iniciada pelo usuário na lista |
| `Recurrence` | Verificações agendadas (ex.: alertar demandas vencidas) |

> **Atenção a loops**: `When an item is created or modified` + `Update item` no mesmo fluxo causa loop infinito. Usar condição para verificar qual campo mudou antes de atualizar.

### 4.2) Ações essenciais do SharePoint no fluxo

```
Ação: Get item          → Buscar um item pelo ID
Ação: Update item       → Atualizar campos (status, datas, resultado)
Ação: Get items         → Buscar lista com filtro OData
Ação: Create item       → Criar novo registro (log, histórico)
Ação: Send an HTTP request to SharePoint  → Operações avançadas via REST API
```

**Exemplo de filtro OData em "Get items"** para buscar demandas vencidas e pendentes:
```
StatusDemanda eq 'Pendente' and DataPrazo lt '@{utcNow()}'
```

### 4.3) Estrutura recomendada de fluxo de aprovação

```
[Trigger: Item criado na lista]
    → [Initialize Variable: varStatus = "Pendente"]
    → [Update item: StatusDemanda = "Em análise"]
    → [Send approval: tipo, aprovador, título, detalhes]
    → [Condition: Outcome eq "Approve"]
        → [Sim]
            → [Update item: StatusDemanda = "Aprovado", ResultadoAprovacao = "Aprovado", DataAprovacao = utcNow()]
            → [Notificar solicitante — aprovado]
            → [Notificar responsável — iniciar execução]
        → [Não]
            → [Update item: StatusDemanda = "Reprovado", ResultadoAprovacao = "Reprovado", JustificativaAprovacao = comments]
            → [Notificar solicitante — reprovado com justificativa]
```

---

## 5) Tipos de aprovação no Power Automate

### 5.1) Aprovação simples (um aprovador)
```json
Tipo: "Approve/Reject - First to respond"
Aprovadores: ["email@empresa.com"]
Título: "Aprovação de demanda: [Título]"
Detalhes: "[Descrição completa]"
```

### 5.2) Aprovação em série (múltiplos aprovadores sequenciais)
Usar **aprovações em sequência** com condições encadeadas:
```
→ [Start approval 1: Aprovador A]
    → [Condition: Outcome 1 = "Approve"]
        → [Start approval 2: Aprovador B]
            → [Condition: Outcome 2 = "Approve"]
                → [Aprovado por todos]
            → [Não] → [Reprovado pelo Aprovador B]
        → [Não] → [Reprovado pelo Aprovador A]
```

### 5.3) Aprovação paralela (qualquer um aprova)
```
Tipo: "Approve/Reject - First to respond"
Aprovadores: ["aprovador1@empresa.com", "aprovador2@empresa.com", "aprovador3@empresa.com"]
```
O primeiro a responder define o resultado.

### 5.4) Aprovação paralela (todos devem aprovar)
```
Tipo: "Approve/Reject - Everyone must approve"
Aprovadores: ["aprovador1@empresa.com", "aprovador2@empresa.com"]
```
Todos precisam aprovar; um "Reject" encerra como reprovado.

### 5.5) Timeout de aprovação (SLA de resposta)
Adicionar ação **"Configure run after"** com timeout usando a ação paralela do Power Automate:
```
[Apply to each: aprovações com timeout]
    → Usar "Do Until" com condição de prazo:
      → Condição: DataAtual > DataPrazo OU Aprovação concluída
      → Se timeout: Update item status = "Aguardando aprovação - Prazo vencido"
      → Enviar lembrete por e-mail/Teams
```

---

## 6) Funções e expressões JSON no Power Automate

### 6.1) Estrutura de expressões
No Power Automate, expressões ficam dentro de `@{ }` ou são usadas diretamente em campos de ação.
Acesse o editor de expressões clicando no campo e escolhendo **"Expressão"** na aba de conteúdo dinâmico.

### 6.2) Funções de string

```
// Concatenar texto
concat('Demanda ', triggerOutputs()?['body/Title'])

// Parte de string
substring('Status: Pendente', 8, 8)      → "Pendente"

// Substituir texto
replace(variables('varTexto'), 'antigo', 'novo')

// Converter para maiúsculo/minúsculo
toUpper(triggerOutputs()?['body/Title'])
toLower(triggerOutputs()?['body/Title'])

// Remover espaços
trim('  texto com espaços  ')

// Verificar se contém
contains(triggerOutputs()?['body/Descricao'], 'urgente')

// Comprimento
length(variables('varLista'))
```

### 6.3) Funções de data e hora

```
// Data/hora atual (UTC)
utcNow()                                  → "2024-06-17T14:30:00.0000000Z"

// Formatar data para exibição (PT-BR)
formatDateTime(utcNow(), 'dd/MM/yyyy HH:mm')

// Adicionar dias/horas
addDays(utcNow(), 5)                      → 5 dias a partir de hoje
addHours(utcNow(), 48)
addMinutes(utcNow(), 30)

// Comparar datas (retorna true/false)
less(triggerOutputs()?['body/DataPrazo'], utcNow())    → prazo vencido?
greater(variables('varDataPrazo'), utcNow())           → prazo no futuro?

// Diferença entre datas (em ticks → converter para dias)
div(
  sub(
    ticks(utcNow()),
    ticks(triggerOutputs()?['body/DataAbertura'])
  ),
  864000000000
)
// Resultado: dias decorridos desde a abertura

// Converter string de data para objeto de data
parseDateTime('2024-06-17', 'yyyy-MM-dd')
```

### 6.4) Funções condicionais

```
// if simples
if(equals(variables('varStatus'), 'Aprovado'), 'Prosseguir', 'Bloquear')

// Verificar nulo/vazio
if(empty(triggerOutputs()?['body/Aprovador']), 'Sem aprovador', 'Com aprovador')

// Coalesce (usar primeiro valor não nulo)
coalesce(triggerOutputs()?['body/Responsavel/Email'], 'padrao@empresa.com')

// Checar igualdade / desigualdade
equals(variables('varResultado'), 'Approve')
not(equals(variables('varStatus'), 'Concluído'))
```

### 6.5) Funções de array e objeto

```
// Criar array
createArray('Pendente', 'Em análise', 'Aprovado')

// Verificar se valor está no array
contains(createArray('Alta', 'Crítica'), triggerOutputs()?['body/Prioridade'])

// Primeiro / último item
first(variables('varListaAprovadores'))
last(variables('varListaAprovadores'))

// Tamanho do array
length(variables('varItens'))

// Unir array em string
join(createArray('A', 'B', 'C'), ', ')   → "A, B, C"

// Acessar propriedade de objeto JSON
triggerOutputs()?['body/Aprovador/DisplayName']
triggerOutputs()?['body/Aprovador/Email']
```

### 6.6) Parse e criação de JSON dinâmico

**Parse JSON** — usar quando uma ação retorna texto JSON e você quer acessar propriedades:
1. Adicionar ação **Parse JSON**.
2. Definir o conteúdo (output de ação anterior).
3. Gerar o schema automaticamente clicando em "Gerar do payload de exemplo" e colando um exemplo do JSON esperado.

**Exemplo de schema para resposta de aprovação:**
```json
{
  "type": "object",
  "properties": {
    "outcome": { "type": "string" },
    "comments": { "type": "string" },
    "responderEmail": { "type": "string" },
    "responseDate": { "type": "string" }
  }
}
```

**Criar JSON dinâmico com Compose:**
```json
{
  "demandaId": "@{triggerOutputs()?['body/ID']}",
  "titulo": "@{triggerOutputs()?['body/Title']}",
  "solicitante": "@{triggerOutputs()?['body/Solicitante/DisplayName']}",
  "dataCriacao": "@{formatDateTime(utcNow(), 'dd/MM/yyyy HH:mm')}",
  "status": "@{variables('varStatus')}",
  "prioridade": "@{triggerOutputs()?['body/Prioridade']}"
}
```

### 6.7) Variáveis no fluxo

```
// Inicializar (obrigatório antes de usar)
Initialize variable: nome="varStatus", tipo="String", valor="Pendente"

// Atribuir novo valor
Set variable: nome="varStatus", valor="Aprovado"

// Incrementar (tipo Integer)
Increment variable: nome="varContador", valor=1

// Append (tipo Array ou String)
Append to array variable: nome="varLista", valor=@{items('Apply_to_each')}
Append to string variable: nome="varLog", valor="[linha nova]"
```

---

## 7) Integração com Microsoft Teams

### 7.1) Enviar mensagem em canal (simples)
```
Ação: Post message in a chat or channel
Canal: [canal destino]
Mensagem: 
"📋 Nova demanda criada
Título: @{triggerOutputs()?['body/Title']}
Solicitante: @{triggerOutputs()?['body/Solicitante/DisplayName']}
Prioridade: @{triggerOutputs()?['body/Prioridade']}
Prazo: @{formatDateTime(triggerOutputs()?['body/DataPrazo'], 'dd/MM/yyyy')}
🔗 @{triggerOutputs()?['body/{Link}']}}"
```

### 7.2) Adaptive Card para Teams (aprovação com botões)
Use **Post an Adaptive Card and wait for a response** para aprovação diretamente no Teams.

**Template de Adaptive Card para aprovação:**
```json
{
  "type": "AdaptiveCard",
  "version": "1.4",
  "body": [
    {
      "type": "TextBlock",
      "text": "📋 Aprovação de Demanda",
      "weight": "Bolder",
      "size": "Large",
      "color": "Accent"
    },
    {
      "type": "FactSet",
      "facts": [
        { "title": "Título:", "value": "@{triggerOutputs()?['body/Title']}" },
        { "title": "Solicitante:", "value": "@{triggerOutputs()?['body/Solicitante/DisplayName']}" },
        { "title": "Prioridade:", "value": "@{triggerOutputs()?['body/Prioridade']}" },
        { "title": "Prazo:", "value": "@{formatDateTime(triggerOutputs()?['body/DataPrazo'], 'dd/MM/yyyy')}" },
        { "title": "Descrição:", "value": "@{triggerOutputs()?['body/Descricao']}" }
      ]
    }
  ],
  "actions": [
    {
      "type": "Action.ShowCard",
      "title": "✅ Aprovar",
      "card": {
        "type": "AdaptiveCard",
        "body": [
          {
            "type": "Input.Text",
            "id": "comentario",
            "placeholder": "Comentário (opcional)",
            "isMultiline": true
          }
        ],
        "actions": [
          {
            "type": "Action.Submit",
            "title": "Confirmar aprovação",
            "data": { "resultado": "Aprovado" }
          }
        ]
      }
    },
    {
      "type": "Action.ShowCard",
      "title": "❌ Reprovar",
      "card": {
        "type": "AdaptiveCard",
        "body": [
          {
            "type": "Input.Text",
            "id": "comentario",
            "placeholder": "Justificativa da reprovação (obrigatório)",
            "isMultiline": true
          }
        ],
        "actions": [
          {
            "type": "Action.Submit",
            "title": "Confirmar reprovação",
            "data": { "resultado": "Reprovado" }
          }
        ]
      }
    }
  ]
}
```

**Como usar no fluxo:**
1. Ação: **Post an Adaptive Card and wait for a response**
2. Definir o JSON acima no campo "Card".
3. O fluxo aguarda até o usuário clicar em um botão.
4. Acessar resposta: `body('Post_an_Adaptive_Card')?['data']?['resultado']`
5. Acessar comentário: `body('Post_an_Adaptive_Card')?['data']?['comentario']`

### 7.3) Notificação pessoal (Teams chat direto)
```
Ação: Post message in a chat or channel
Post as: Flow bot
Post in: Chat with Flow bot
Recipient: @{triggerOutputs()?['body/Solicitante/Email']}
Message: "Sua demanda '@{triggerOutputs()?['body/Title']}' foi @{variables('varResultado')}."
```

### 7.4) Threads no Teams — padrão de conversa por demanda

Permite que todas as notificações de uma demanda sejam respostas em um único thread no canal, mantendo o histórico organizado.

**Preparação na lista SharePoint:**
Adicionar coluna `TeamsThreadId` (Linha de texto única, não obrigatória, oculta do formulário).

**Passo 1 — Postar card no canal e salvar o ID do thread:**
```
Ação: Postar cartão adaptável em um chat ou canal
Postar em: Canal
Canal: [canal destino]
Mensagem: [JSON do Adaptive Card]

→ Retorna: outputs('NomeAcaoCard')?['body/id']  ← este é o TeamsThreadId

Ação: Atualizar item
TeamsThreadId: outputs('NomeAcaoCard')?['body/id']
Atualizado pelo fluxo: Sim
```

**Passo 2 — Responder no thread em fluxos subsequentes:**
```
Ação: Postar mensagem em um chat ou canal
Postar em: Canal
Canal: [canal destino]
ID da mensagem pai: triggerOutputs()?['body/TeamsThreadId']
Mensagem: [conteúdo da atualização]
```

**Resultado visual:**
```
Canal Teams
└── 🆕 Card — Chamado #110: [Título]           ← mensagem original
      ├── ✅ Aprovado — Status: Priorizado       ← reply Fluxo 1
      ├── 👤 Responsável atualizado              ← reply Fluxo 3
      ├── 🔄 Status: Em Andamento                ← reply Fluxo 3
      └── ✅ Concluído                           ← reply Fluxo 3
```

> **Atenção:** o `TeamsThreadId` só existe após a primeira postagem. Em fluxos subsequentes, verificar se o campo não está vazio antes de usar como ID da mensagem pai para evitar erro.

---

## 8) Integração com Outlook

### 8.1) E-mail simples de notificação
```
Ação: Send an email (V2)
Para: @{triggerOutputs()?['body/Solicitante/Email']}
Assunto: [Demanda @{triggerOutputs()?['body/ID']}] @{variables('varResultado')}: @{triggerOutputs()?['body/Title']}
Corpo: [HTML abaixo]
```

### 8.2) Template de e-mail HTML para notificação de resultado
```html
<!DOCTYPE html>
<html>
<body style="font-family:Segoe UI,Arial,sans-serif;background:#f4f4f4;padding:20px">
  <div style="max-width:600px;margin:auto;background:#fff;border-radius:8px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.1)">
    
    <!-- Cabeçalho colorido por resultado -->
    <div style="background:@{if(equals(variables('varResultado'),'Aprovado'),'#2ECC71','#E74C3C')};padding:24px 32px">
      <h2 style="color:#fff;margin:0">
        @{if(equals(variables('varResultado'),'Aprovado'),'✅ Demanda Aprovada','❌ Demanda Reprovada')}
      </h2>
    </div>
    
    <!-- Corpo -->
    <div style="padding:32px">
      <p style="color:#333;font-size:15px">Olá, <strong>@{triggerOutputs()?['body/Solicitante/DisplayName']}</strong>,</p>
      <p style="color:#555;font-size:14px">
        Sua demanda foi <strong>@{variables('varResultado')}</strong> por <strong>@{variables('varAprovadorNome')}</strong>.
      </p>
      
      <!-- Tabela de detalhes -->
      <table style="width:100%;border-collapse:collapse;margin:20px 0;font-size:14px">
        <tr style="background:#f8f8f8">
          <td style="padding:10px 14px;font-weight:600;color:#555;width:35%">Demanda</td>
          <td style="padding:10px 14px;color:#333">@{triggerOutputs()?['body/Title']}</td>
        </tr>
        <tr>
          <td style="padding:10px 14px;font-weight:600;color:#555">ID</td>
          <td style="padding:10px 14px;color:#333">#@{triggerOutputs()?['body/ID']}</td>
        </tr>
        <tr style="background:#f8f8f8">
          <td style="padding:10px 14px;font-weight:600;color:#555">Prioridade</td>
          <td style="padding:10px 14px;color:#333">@{triggerOutputs()?['body/Prioridade']}</td>
        </tr>
        <tr>
          <td style="padding:10px 14px;font-weight:600;color:#555">Data da decisão</td>
          <td style="padding:10px 14px;color:#333">@{formatDateTime(utcNow(), 'dd/MM/yyyy HH:mm')}</td>
        </tr>
        <tr style="background:#f8f8f8">
          <td style="padding:10px 14px;font-weight:600;color:#555">Comentário</td>
          <td style="padding:10px 14px;color:#333">@{coalesce(variables('varComentario'), 'Sem comentário')}</td>
        </tr>
      </table>
      
      <!-- Link para o item -->
      <div style="text-align:center;margin:24px 0">
        <a href="@{triggerOutputs()?['body/{Link}']}"
           style="background:#0078D4;color:#fff;padding:12px 28px;border-radius:6px;text-decoration:none;font-size:14px;font-weight:600">
          Abrir demanda no SharePoint
        </a>
      </div>
    </div>
    
    <!-- Rodapé -->
    <div style="background:#f4f4f4;padding:16px 32px;border-top:1px solid #eee">
      <p style="color:#999;font-size:12px;margin:0">
        Esta mensagem foi gerada automaticamente. Não responda a este e-mail.
      </p>
    </div>
  </div>
</body>
</html>
```

### 8.3) E-mail com aprovação direta pelo Outlook (Action Buttons)
```
Ação: Send approval email
Para: @{triggerOutputs()?['body/Aprovador/Email']}
Assunto: [Aprovação necessária] @{triggerOutputs()?['body/Title']}
Opções do usuário: "Aprovar, Reprovar"
Corpo: [detalhes da demanda]
```
O fluxo pausa até o aprovador responder diretamente pelo e-mail (sem abrir o SharePoint).
Acessar resposta: `body('Send_approval_email')?['SelectedOption']`

---

## 9) Gestão de demandas — Ciclo de vida completo

### 9.1) Mapa de status
```
[Pendente] 
    → (fluxo inicia aprovação) → [Em análise]
        → (aprovado) → [Aprovado] → [Em execução] → [Concluído]
        → (reprovado) → [Reprovado]
        → (cancelado pelo solicitante) → [Cancelado]
        → (timeout sem resposta) → [Aguardando aprovação - Vencido]
```

### 9.2) Fluxo completo de gestão de demanda (estrutura de referência)

```
FLUXO 1 — "Nova demanda criada"
Trigger: When an item is created (lista Demandas)
    1. Update item → StatusDemanda = "Em análise"
    2. Start approval (aprovador da demanda)
    3. [Condition] Resultado = "Approve"
        Sim:
            4a. Update item → StatusDemanda = "Aprovado", DataAprovacao, JustificativaAprovacao
            5a. Post Teams card → canal de gestão (demanda aprovada)
            6a. Send email → solicitante (aprovado)
            7a. Send email → responsável (iniciar execução)
            8a. Update item → StatusDemanda = "Em execução"
        Não:
            4b. Update item → StatusDemanda = "Reprovado", JustificativaAprovacao
            5b. Send email → solicitante (reprovado + justificativa)

FLUXO 2 — "Demanda concluída"
Trigger: When an item is modified (filtro: StatusDemanda = "Concluído")
    1. Update item → DataConclusao = utcNow()
    2. Send email → solicitante (concluído)
    3. Post Teams message → canal de gestão

FLUXO 3 — "Lembrete de demandas vencidas" (agendado)
Trigger: Recurrence — todos os dias às 08:00
    1. Get items → filtro: StatusDemanda eq 'Em execução' and DataPrazo lt '@{utcNow()}'
    2. Apply to each (demanda vencida):
        3. Send email → responsável (lembrete de prazo vencido)
        4. Post Teams → canal de gestão (alerta)
```

### 9.3) Prevenção de loop em fluxos de modificação
Quando usar `When an item is modified`, sempre adicionar uma condição logo no início:

```
[Condition] triggerOutputs()?['body/StatusDemanda'] is not equal to triggerOutputs()?['body/{Versão anterior}']
```
Ou usar a técnica de **variável de controle**:
```
1. Get item (buscar o item atual)
2. Condition: StatusDemanda (atual) ne StatusDemanda (trigger)
    → Só prosseguir se o status realmente mudou
```

### 9.5) Controle de loop com campo semáforo (padrão AtualizadoPeloFluxo)

Padrão recomendado quando o fluxo precisa atualizar o próprio item sem re-disparar a lógica principal.

**Configuração:**
- Adicionar coluna `AtualizadoPeloFluxo` (Sim/Não) na lista, não obrigatória
- Em todo "Atualizar item" feito pelo fluxo, incluir `AtualizadoPeloFluxo = Sim`

**Estrutura no início de todo fluxo de modificação:**
```
Condição: triggerOutputs()?['body/AtualizadoPeloFluxo'] = true
    Verdadeiro:
        Atualizar item → AtualizadoPeloFluxo = Não  (reset)
        Terminar → Com Êxito
    Falso:
        (continua o fluxo normalmente)
```

**Por que funciona:** quando o fluxo atualiza o item com o campo = Sim, o gatilho re-dispara. A condição detecta o flag, reseta para Não e encerra — sem processar como uma mudança real do usuário.

### 9.6) Detecção de campos alterados com "Obter alterações"

Permite identificar exatamente quais colunas foram modificadas em uma execução específica, sem precisar de colunas sombra.

**Ação:** `Obter alterações de um item ou um arquivo (somente propriedades)`
- **ID:** `triggerOutputs()?['body/ID']`
- **Desde:** deixar em branco (detecta alterações da versão anterior automaticamente)

**Estrutura de retorno:**
```json
{
  "body": {
    "ColumnHasChanged": {
      "Status": true,
      "Responsavel": false,
      "Prazoestimado": false,
      ...
    }
  }
}
```

**Expressão para verificar se um campo mudou:**
```
body('ObterAlteracoes')?['ColumnHasChanged']?['NomeDoCampo']
```
Usar em condição: `é igual a` → `true`

**Nomes internos comuns com caracteres especiais:**
```
Descrição      → Descri_x00e7__x00e3_o
Responsável    → Respons_x00e1_vel
Aprovado?      → Aprovado_x003f_
Espaço         → _x0020_   (ex: "Data Abertura" → DataAbertura ou Data_x0020_Abertura)
```

> **Importante:** o nome interno é definido na **criação** da coluna e nunca muda mesmo que ela seja renomeada. Para descobrir o nome interno: acessar Configurações da coluna e verificar o parâmetro `Field=` na URL.

### 9.4) Log de histórico (auditoria)
Criar uma lista separada `HistoricoDemandas` para registrar cada transição de status:

| Coluna | Tipo |
|---|---|
| `IDDemanda` | Número (referência) |
| `TituloDemanda` | Linha de texto |
| `StatusAnterior` | Linha de texto |
| `StatusNovo` | Linha de texto |
| `UsuarioAcao` | Pessoa/Grupo |
| `DataHora` | Data e hora |
| `Comentario` | Várias linhas |

No fluxo, após cada mudança de status:
```
Ação: Create item (lista HistoricoDemandas)
IDDemanda: @{triggerOutputs()?['body/ID']}
StatusNovo: @{variables('varStatus')}
DataHora: @{utcNow()}
```

---

## 10) Boas práticas obrigatórias

### Fluxos
- **Nomear fluxos com padrão**: `[Lista] — [Evento] — [Ação]` (ex.: `Demandas — Item criado — Iniciar aprovação`).
- **Nomear todas as ações** no fluxo (clicar nos "..." e renomear) — facilita a leitura das expressões `body('Nome_da_acao')`.
- **Usar variáveis** para valores reutilizados no fluxo (ex.: nome do aprovador, resultado, e-mail).
- **Tratar erros**: usar "Configure run after" → "has failed" nas ações críticas para enviar alerta ao administrador.
- **Não hardcodar e-mails**: usar colunas de Pessoa/Grupo do SharePoint para e-mails dinâmicos.
- **Testar com dados reais** antes de publicar: criar um item de teste na lista e verificar cada etapa do fluxo no histórico de execuções.

### SharePoint
- **Um fluxo = uma responsabilidade**: não criar um fluxo "faz tudo". Separar criação, aprovação, conclusão e alertas em fluxos distintos.
- **Ambientes**: desenvolver no ambiente de desenvolvimento, publicar no de produção — nunca testar direto em produção.
- **Backup de fluxos**: exportar o fluxo (.zip) após qualquer mudança relevante. Salvar em `/docs/flows-backup/`.

---

## 11) Erros comuns a evitar

| Erro | Consequência | Solução |
|---|---|---|
| Usar `When an item is created or modified` + `Update item` sem condição | Loop infinito | Adicionar condição de controle antes de atualizar |
| Hardcodar e-mail de aprovador | Falha ao trocar de responsável | Usar coluna `Pessoa/Grupo` dinâmica |
| Não tratar BLANK em campos de pessoa | Erro na expressão de e-mail | Usar `coalesce()` com e-mail padrão de fallback |
| `Parse JSON` sem schema gerado | Acesso aos campos quebra em runtime | Sempre gerar schema pelo "payload de exemplo" |
| Approval sem timeout | Fluxo fica preso indefinidamente | Sempre usar Do Until ou ação paralela com prazo |
| Fluxo desabilitado silenciosamente pelo Power Automate | Automação para sem aviso | Monitorar com alertas de falha ou verificação semanal |
| Expressões de data sem formatação | Datas em UTC sem timezone correto | Usar `convertTimeZone(utcNow(), 'UTC', 'E. South America Standard Time')` para horário de Brasília |

**Converter UTC para horário de Brasília:**
```
convertTimeZone(utcNow(), 'UTC', 'E. South America Standard Time', 'dd/MM/yyyy HH:mm')
```

---

## 12) Templates de fluxo reutilizáveis

### Template A — Notificação simples ao criar item
```
Trigger: When an item is created
→ Send email: solicitante
→ Post Teams message: canal
```
Usar como base para qualquer lista que precise de notificação de criação.

### Template B — Aprovação com fallback de timeout
```
Trigger: When an item is created
→ Initialize variable: varAprovado = false
→ Do Until: varAprovado OR DataAtual > DataPrazoAprovacao
    → Start approval (timeout interno)
    → Set variable: varAprovado = true / false
→ Condition: varAprovado
    → Aprovado: atualizar status + notificar
    → Timeout: atualizar status "Vencido" + escalar
```

### Template C — Verificação periódica e alerta
```
Trigger: Recurrence (diário 08:00)
→ Get items (filtro OData: status + prazo)
→ Condition: length(body('Get_items')?['value']) > 0
    → Sim: Apply to each → enviar alerta individual
    → Não: (nenhuma ação — fluxo encerra normalmente)
```

---

## Checklist de publicação

**Formulário (SharePoint):**
- [ ] Todas as colunas de status usam tipo "Escolha" com valores fixos?
- [ ] Colunas preenchidas automaticamente (datas, resultado) estão protegidas contra edição manual?
- [ ] Permissões por grupo estão configuradas (não por usuário individual)?
- [ ] Valor padrão do status está definido como "Pendente"?

**Fluxo (Power Automate):**
- [ ] O fluxo tem nome descritivo seguindo o padrão `[Lista] — [Evento] — [Ação]`?
- [ ] Todas as ações críticas estão renomeadas para facilitar debug?
- [ ] Existe proteção contra loop (condição antes de qualquer `Update item`)?
- [ ] Existe tratamento de erro nas ações críticas (e-mail, aprovação, update)?
- [ ] Datas são exibidas no fuso horário correto (Brasília)?
- [ ] Aprovações têm timeout definido?
- [ ] O fluxo foi testado com item real antes de publicar?
- [ ] O fluxo foi exportado como backup?

**Integração:**
- [ ] E-mails e mensagens Teams usam campos dinâmicos (não hardcoded)?
- [ ] O link do item SharePoint (`{Link}`) está incluído nas notificações?
- [ ] Adaptive Cards foram testados no Teams antes de publicar?
- [ ] Se usar threads: coluna `TeamsThreadId` existe na lista e está oculta no formulário?
- [ ] Se usar threads: ação de reply usa `ID da mensagem pai` com `triggerOutputs()?['body/TeamsThreadId']`?
- [ ] Se usar "Obter alterações": ação renomeada sem acentos/caracteres especiais?
- [ ] Nomes internos de colunas com acento foram verificados via URL das configurações da coluna?
