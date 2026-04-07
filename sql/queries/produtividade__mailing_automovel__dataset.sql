-- Produtividade: dataset de performance do mailing automóvel (SQL Server / Power BI)
--
-- Objetivo:
-- - Gerar um dataset pronto para Power BI para analisar performance operacional de mailing de vendas,
--   com foco em produtividade, conversão e valor (soma de prêmio) por campanha/origem.
--
-- Fontes:
-- - automovel.Mailing_Venda
-- - automovel.Mailing_Venda_Tabulacoes
-- - automovel.Mailing_Venda_Tipo_Origem (opcional; de/para de tipo_origem/campanha)
--
-- Granularidade:
-- - 1 linha por (mailing_id, dt_evento) (data driver do período)
--   Observação: se sua tabela de tabulações estiver no grão por evento_id, este dataset preserva evento.
--
-- Data driver (filtro de período):
-- - t.dt_evento
--
-- Parâmetros (opcionais):
-- - @DataInicio: início do período (inclusive)
-- - @DataFim: fim do período (inclusive)
-- - @SomenteCampanha: filtra uma campanha específica (NULL para todas)
--
-- Observações de performance:
-- - Ideal ter índice/particionamento em automovel.Mailing_Venda_Tabulacoes(dt_evento)
-- - Evite funções em dt_evento no WHERE (mantenha sargável)

DECLARE @DataInicio date = NULL;
DECLARE @DataFim date = NULL;
DECLARE @SomenteCampanha nvarchar(200) = NULL;

WITH tab AS (
    SELECT
        t.mailing_id,
        t.evento_id,
        t.dt_evento,

        t.campanha,
        t.grupo_campanha,
        t.origem,
        t.grupo_origem,
        t.classe_processo,
        t.tipo_processo,

        t.qtd_cpcs,
        t.qtd_agendamentos,
        t.qtd_contratacoes,
        t.soma_premio AS soma_premio_tabulacoes,

        t.aceitou_ouvir,
        t.nova_cotacao,
        t.cpc
    FROM automovel.Mailing_Venda_Tabulacoes AS t WITH (NOLOCK)
    WHERE
        (@DataInicio IS NULL OR t.dt_evento >= @DataInicio)
        AND (@DataFim IS NULL OR t.dt_evento < DATEADD(DAY, 1, @DataFim))
        AND (@SomenteCampanha IS NULL OR t.campanha = @SomenteCampanha)
),
mailing AS (
    SELECT
        m.cpf_cnpj,
        m.cliente_id,
        m.mailing_id,
        m.data_carga,
        m.tipo_origem,
        m.cd_origem_age,

        m.campanha_id,
        m.campanha,
        m.grupo_campanha,

        m.lista_id,
        m.lista,
        m.status_lista,

        m.trabalhados,
        m.qtd_tentativas,
        m.contatados,
        m.cpc,
        m.sucesso,
        m.quantidade_sucesso,
        m.soma_premio AS soma_premio_mailing,

        m.dt_contratacao,
        m.grupo_origem,
        m.classe_processo,
        m.grupo_processo,
        m.tipo_processo,
        m.dt_status
    FROM automovel.Mailing_Venda AS m WITH (NOLOCK)
),
origem_depara AS (
    SELECT
        o.tipo_origem,
        o.campanha AS campanha_tipo_origem
    FROM automovel.Mailing_Venda_Tipo_Origem AS o WITH (NOLOCK)
)
SELECT
    -- Chaves
    t.mailing_id,
    t.evento_id,

    -- Data driver
    t.dt_evento,

    -- Dimensões (preferir tabulação para cortes operacionais por evento)
    t.campanha,
    t.grupo_campanha,
    t.origem,
    t.grupo_origem,
    t.classe_processo,
    t.tipo_processo,

    -- Atributos do mailing (cadastro/base)
    m.cpf_cnpj,
    m.cliente_id,
    m.data_carga,
    m.tipo_origem,
    od.campanha_tipo_origem,
    m.cd_origem_age,

    m.lista_id,
    m.lista,
    m.status_lista,

    -- Sinais operacionais (mailing)
    m.trabalhados,
    m.qtd_tentativas,
    m.contatados,
    m.cpc AS cpc_mailing,
    m.sucesso,
    m.quantidade_sucesso,

    -- Sinais operacionais (tabulação/evento)
    t.qtd_cpcs,
    t.qtd_agendamentos,
    t.qtd_contratacoes,
    t.cpc AS cpc_evento,
    t.aceitou_ouvir,
    t.nova_cotacao,

    -- Valor
    m.soma_premio_mailing,
    t.soma_premio_tabulacoes,
    COALESCE(t.soma_premio_tabulacoes, m.soma_premio_mailing) AS soma_premio_ref,

    -- Datas de resultado/status (do mailing)
    m.dt_contratacao,
    m.dt_status,

    -- Flags utilitárias (para medidas)
    CASE WHEN m.contatados IS NULL THEN NULL WHEN m.contatados > 0 THEN 1 ELSE 0 END AS flag_contato_mailing,
    CASE WHEN t.qtd_contratacoes IS NULL THEN NULL WHEN t.qtd_contratacoes > 0 THEN 1 ELSE 0 END AS flag_contratacao_evento,
    CASE WHEN m.dt_contratacao IS NULL THEN 0 ELSE 1 END AS flag_contratacao_mailing
FROM tab AS t
LEFT JOIN mailing AS m
    ON m.mailing_id = t.mailing_id
LEFT JOIN origem_depara AS od
    ON od.tipo_origem = m.tipo_origem;

-- Variação (opcional): agregação diária para visuais leves (use como dataset separado)
-- SELECT
--   CAST(t.dt_evento AS date) AS periodo_dia,
--   t.campanha,
--   t.grupo_campanha,
--   t.origem,
--   t.grupo_origem,
--   COUNT(DISTINCT t.mailing_id) AS qtde_mailings,
--   SUM(COALESCE(t.qtd_cpcs, 0)) AS qtd_cpcs,
--   SUM(COALESCE(t.qtd_agendamentos, 0)) AS qtd_agendamentos,
--   SUM(COALESCE(t.qtd_contratacoes, 0)) AS qtd_contratacoes,
--   SUM(COALESCE(t.soma_premio, 0)) AS soma_premio
-- FROM automovel.Mailing_Venda_Tabulacoes t
-- WHERE (@DataInicio IS NULL OR t.dt_evento >= @DataInicio)
--   AND (@DataFim IS NULL OR t.dt_evento < DATEADD(DAY, 1, @DataFim))
-- GROUP BY CAST(t.dt_evento AS date), t.campanha, t.grupo_campanha, t.origem, t.grupo_origem;
