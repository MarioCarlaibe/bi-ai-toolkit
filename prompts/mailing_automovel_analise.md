# 🚗 Prompt - Análise de Mailing de Seguros Automotivos

## 🧠 Contexto

Considere os arquivos:

* contexto.md
* padroes_sla.md
* sql_skill.md
* dax_skill.md
* analise_skill.md

Estou trabalhando com dados de mailing de vendas de seguros automotivos.

---

## 🗄️ Estrutura das Tabelas

### 📌 automovel.Mailing_Venda

* cpf_cnpj
* cliente_id
* mailing_id
* data_carga
* tipo_origem
* cd_origem_age
* campanha_id
* campanha
* grupo_campanha
* lista_id
* lista
* status_lista
* trabalhados
* qtd_tentativas
* contatados
* cpc
* sucesso
* quantidade_sucesso
* soma_premio
* dt_contratacao
* grupo_origem
* classe_processo
* grupo_processo
* tipo_processo
* dt_status

---

### 📌 automovel.Mailing_Venda_Tabulacoes

* mailing_id
* qtd_cpcs
* qtd_agendamentos
* qtd_contratacoes
* soma_premio
* aceitou_ouvir
* nova_cotacao
* classe_processo
* tipo_processo
* cpc
* evento_id
* dt_evento
* campanha
* grupo_campanha
* origem
* grupo_origem

---

### 📌 automovel.Mailing_Venda_Tipo_Origem

* tipo_origem
* campanha

---

## 🎯 Objetivo

Quero analisar a performance do mailing de vendas, considerando:

* produtividade (tentativas, contatos, sucesso)
* conversão (contratações)
* eficiência por campanha e origem
* valor gerado (soma_premio)
* comportamento operacional

---

## 🚀 Solicitação

Com base nisso:

1. Crie uma query SQL completa para análise de performance do mailing
2. Estruture os principais indicadores para Power BI
3. Sugira métricas DAX relevantes
4. Identifique possíveis insights de negócio
5. Aplique boas práticas de performance e organização

---

## ⚠️ Regras

* Priorizar performance
* Evitar SELECT *
* Preparar dados para uso direto no Power BI
* Manter clareza e padronização
* Pensar como analista de dados sênior

---

## 💡 Objetivo final

Gerar uma base analítica pronta para criação de dashboard de vendas de seguros automotivos.
