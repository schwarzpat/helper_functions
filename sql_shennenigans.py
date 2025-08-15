from impala.dbapi import connect
import polars as pl

def run_impala_sql(sql_file, **params):
    # Load SQL and safely format
    sql = Path(sql_file).read_text(encoding="utf-8")
    sql = sql.format(**params)  # only safe if params are trusted

    conn = connect(host='impala-host', port=21050)
    try:
        df = pl.read_database(sql, conn)
    finally:
        conn.close()
    return df

# Example usage
df = run_impala_sql(
    "query.sql",
    start="2025-01-01",
    stop="2025-02-01"
)


OR

from pathlib import Path
from impala.dbapi import connect
import polars as pl

def run_impala_sql(sql_file, **params):
    # Load SQL and insert trusted parameters
    sql = Path(sql_file).read_text(encoding="utf-8")
    sql = sql.format(**params)  # Only safe if params are trusted

    conn = connect(host='impala-host', port=21050)
    try:
        df = pl.read_database(sql, conn)
    finally:
        conn.close()

    # Detect date/datetime-like strings and convert
    df = _convert_date_columns(df)
    return df


def _convert_date_columns(df: pl.DataFrame) -> pl.DataFrame:
    # Patterns for detection
    date_formats = [
        "%Y-%m-%d",                 # date
        "%Y-%m-%d %H:%M:%S",        # datetime without ms
        "%Y-%m-%d %H:%M:%S%.f"      # datetime with ms
    ]

    for col in df.columns:
        if df[col].dtype == pl.Utf8:
            sample_non_null = df[col].drop_nulls().head(5).to_list()
            if not sample_non_null:
                continue
            try:
                # Try each format
                for fmt in date_formats:
                    pl.Series("", sample_non_null).str.strptime(pl.Date, fmt, strict=True)
                # If no exception: convert whole column
                try:
                    df = df.with_columns(pl.col(col).str.strptime(pl.Date, "%Y-%m-%d"))
                except pl.exceptions.ComputeError:
                    df = df.with_columns(pl.col(col).str.strptime(pl.Datetime, "%Y-%m-%d %H:%M:%S", strict=False))
                break
            except pl.exceptions.ComputeError:
                continue
    return df


SELECT *
FROM metrics
WHERE id = {metric_id}

sql = Path("query.sql").read_text()
sql = sql.format(metric_id=42)
