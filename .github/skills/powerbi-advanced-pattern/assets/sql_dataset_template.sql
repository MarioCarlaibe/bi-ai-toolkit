-- TEMPLATE: Dataset SQL (SQL Server) para Power BI
-- Objetivo:
-- - Gerar dataset reutilizável para análises por período e por equipe/setor.
--
-- Preencha/ajuste:
-- - Tabela fato (ex.: dbo.Demandas)
-- - Colunas: DataAbertura, DataConclusao, DataVencimento, Setor, Equipe, Status
--
-- Parâmetros sugeridos (Power BI pode parametrizar via query folding/Power Query):
DECLARE @DataInicio date = NULL;
DECLARE @DataFim   date = NULL;

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
            WHEN d.DataVencimento IS NULL THEN NULL
            WHEN d.DataConclusao IS NOT NULL AND d.DataConclusao > d.DataVencimento THEN 1
            WHEN d.DataConclusao IS NULL AND CAST(GETDATE() AS date) > CAST(d.DataVencimento AS date) THEN 1
            ELSE 0
        END AS FlagAtraso
    FROM dbo.Demandas AS d WITH (NOLOCK)
    WHERE
        -- Escolha UMA data driver para o filtro do período (ex.: DataAbertura)
        (@DataInicio IS NULL OR d.DataAbertura >= @DataInicio)
        AND (@DataFim IS NULL OR d.DataAbertura < DATEADD(DAY, 1, @DataFim))
)
SELECT
    -- Dataset no grão por demanda (recomendado como base para DAX)
    b.IdDemanda,
    b.Setor,
    b.Equipe,
    b.Status,
    b.DataAbertura,
    b.DataConclusao,
    b.DataVencimento,
    b.TempoAtendimentoMinutos,
    b.FlagAtraso
FROM base AS b;

-- Variação (opcional): agregação por período + equipe/setor
-- SELECT
--   DATEFROMPARTS(YEAR(b.DataAbertura), MONTH(b.DataAbertura), 1) AS PeriodoMes,
--   b.Equipe,
--   b.Setor,
--   COUNT(1) AS QtdeDemandas,
--   AVG(CAST(b.TempoAtendimentoMinutos AS decimal(18,2))) AS TempoMedioMinutos,
--   AVG(CAST(b.FlagAtraso AS decimal(18,2))) AS TaxaAtraso
-- FROM base b
-- GROUP BY DATEFROMPARTS(YEAR(b.DataAbertura), MONTH(b.DataAbertura), 1), b.Equipe, b.Setor;
