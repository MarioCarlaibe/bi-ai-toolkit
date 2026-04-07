-- SLA: dataset base (grão por demanda) para Power BI (SQL Server / T-SQL)
--
-- Objetivo:
-- - Entregar uma base “pronta para modelagem” no Power BI para análises de:
--   - tempo de atendimento
--   - demandas em andamento
--   - atraso / SLA fora do prazo (usando DataVencimento)
--   - recortes por período, equipe/setor e status
--
-- Fonte:
-- - dbo.Demandas (ajuste schema/tabela conforme seu modelo)
--
-- Granularidade:
-- - 1 linha por demanda
--
-- Data driver (filtro de período):
-- - DataAbertura (padrão) — ajuste se necessário
--
-- Parâmetros (opcionais):
-- - @DataInicio: início do período (inclusive)
-- - @DataFim: fim do período (inclusive)
-- - @SomenteComVencimento: 1 para manter só demandas com DataVencimento
--
-- Observações de performance:
-- - Mantenha o filtro por período sargável (>= e < + DATEADD)
-- - Ideal ter índice em (DataAbertura) e, se usar recorte, (Setor/Equipe/Status)

DECLARE @DataInicio date = NULL;
DECLARE @DataFim date = NULL;
DECLARE @SomenteComVencimento bit = 0;
DECLARE @Agora datetime2(0) = SYSDATETIME();

WITH base AS (
    SELECT
        d.IdDemanda,
        d.Setor,
        d.Equipe,
        d.Status,
        d.DataAbertura,
        d.DataConclusao,
        d.DataVencimento,

        CASE
            WHEN d.DataAbertura IS NOT NULL
             AND d.DataConclusao IS NOT NULL
             AND d.DataConclusao >= d.DataAbertura
            THEN DATEDIFF(MINUTE, d.DataAbertura, d.DataConclusao)
        END AS TempoAtendimentoMinutos,

        CASE
            WHEN d.DataAbertura IS NOT NULL
             AND COALESCE(d.DataConclusao, @Agora) >= d.DataAbertura
            THEN DATEDIFF(MINUTE, d.DataAbertura, COALESCE(d.DataConclusao, @Agora))
        END AS TempoDecorridoMinutos,

        CASE WHEN d.DataConclusao IS NULL THEN 0 ELSE 1 END AS FlagConcluida,

        CASE
            WHEN d.DataConclusao IS NOT NULL AND d.DataAbertura IS NOT NULL AND d.DataConclusao < d.DataAbertura THEN 1
            ELSE 0
        END AS FlagDataInvalida,

        CASE
            WHEN d.DataVencimento IS NULL THEN NULL
            WHEN d.DataConclusao IS NOT NULL AND d.DataConclusao > d.DataVencimento THEN 1
            WHEN d.DataConclusao IS NULL AND @Agora > d.DataVencimento THEN 1
            ELSE 0
        END AS FlagAtraso,

        CASE
            WHEN d.DataVencimento IS NULL THEN 'Sem vencimento'
            WHEN d.DataConclusao IS NULL THEN 'Em andamento'
            WHEN d.DataConclusao <= d.DataVencimento THEN 'No prazo'
            ELSE 'Fora do prazo'
        END AS StatusSLA,

        CASE
            WHEN d.DataVencimento IS NULL THEN NULL
            WHEN d.DataConclusao IS NOT NULL AND d.DataConclusao > d.DataVencimento THEN DATEDIFF(MINUTE, d.DataVencimento, d.DataConclusao)
            WHEN d.DataConclusao IS NULL AND @Agora > d.DataVencimento THEN DATEDIFF(MINUTE, d.DataVencimento, @Agora)
            ELSE 0
        END AS AtrasoMinutos
    FROM dbo.Demandas AS d
    WHERE
        d.DataAbertura IS NOT NULL
        AND (@SomenteComVencimento = 0 OR d.DataVencimento IS NOT NULL)
        AND (@DataInicio IS NULL OR d.DataAbertura >= @DataInicio)
        AND (@DataFim IS NULL OR d.DataAbertura < DATEADD(DAY, 1, @DataFim))
)
SELECT
    -- Chaves / dimensões
    b.IdDemanda,
    b.Setor,
    b.Equipe,
    b.Status,

    -- Datas (para calendário / análise)
    b.DataAbertura,
    b.DataVencimento,
    b.DataConclusao,

    -- Derivações
    b.FlagConcluida,
    b.FlagAtraso,
    b.StatusSLA,
    b.FlagDataInvalida,

    b.TempoAtendimentoMinutos,
    CAST(b.TempoAtendimentoMinutos / 60.0 AS decimal(18,2)) AS TempoAtendimentoHoras,

    b.TempoDecorridoMinutos,
    CAST(b.TempoDecorridoMinutos / 60.0 AS decimal(18,2)) AS TempoDecorridoHoras,

    b.AtrasoMinutos,
    CAST(b.AtrasoMinutos / 60.0 AS decimal(18,2)) AS AtrasoHoras
FROM base AS b;

-- Variação (opcional): agregação mensal (use como dataset separado, se preferir)
-- SELECT
--     DATEFROMPARTS(YEAR(b.DataAbertura), MONTH(b.DataAbertura), 1) AS PeriodoMes,
--     b.Equipe,
--     b.Setor,
--     COUNT(1) AS QtdeDemandas,
--     SUM(CASE WHEN b.FlagConcluida = 1 THEN 1 ELSE 0 END) AS QtdeConcluidas,
--     SUM(CASE WHEN b.FlagAtraso = 1 THEN 1 ELSE 0 END) AS QtdeAtrasadas,
--     AVG(CAST(b.TempoAtendimentoMinutos AS decimal(18,2))) AS TempoMedioAtendimentoMinutos,
--     AVG(CAST(b.FlagAtraso AS decimal(18,2))) AS TaxaAtraso
-- FROM base AS b
-- GROUP BY DATEFROMPARTS(YEAR(b.DataAbertura), MONTH(b.DataAbertura), 1), b.Equipe, b.Setor;
