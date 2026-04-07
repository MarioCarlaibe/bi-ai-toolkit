-- SLA: tempo médio de atendimento por setor (SQL Server / Power BI)
-- Ajuste os nomes de tabela/colunas conforme seu modelo.
--
-- Parâmetros (opcionais) para filtro por data:
--   @DataInicio: início do período (inclusive)
--   @DataFim: fim do período (inclusive)
--
-- Exemplo de uso:
--   DECLARE @DataInicio date = '2026-01-01';
--   DECLARE @DataFim   date = '2026-01-31';

DECLARE @DataInicio date = NULL;
DECLARE @DataFim   date = NULL;

WITH base AS (
    SELECT
        d.Setor,
        d.DataAbertura,
        d.DataConclusao,
        DATEDIFF(MINUTE, d.DataAbertura, d.DataConclusao) AS TempoAtendimentoMinutos
    FROM dbo.Demandas AS d WITH (NOLOCK)
    WHERE
        d.DataConclusao IS NOT NULL
        AND d.DataAbertura IS NOT NULL
        AND d.DataConclusao >= d.DataAbertura
        AND (@DataInicio IS NULL OR d.DataAbertura >= @DataInicio)
        AND (
            @DataFim IS NULL
            OR d.DataAbertura < DATEADD(DAY, 1, @DataFim)
        )
)
SELECT
    b.Setor,
    COUNT(1) AS QtdeAtendimentos,
    CAST(AVG(CAST(b.TempoAtendimentoMinutos AS decimal(18,2))) AS decimal(18,2)) AS TempoMedioAtendimentoMinutos,
    CAST(AVG(CAST(b.TempoAtendimentoMinutos AS decimal(18,2))) / 60.0 AS decimal(18,2)) AS TempoMedioAtendimentoHoras
FROM base AS b
GROUP BY
    b.Setor
ORDER BY
    TempoMedioAtendimentoMinutos DESC;
