import sqlglot

impala_sql = """
SELECT
  user_id
  , event_date
  , date_format(event_time, 'yyyy-MM-dd') AS event_day
  , SUM(metric) OVER (
      PARTITION BY user_id 
      ORDER BY event_time 
      ROWS BETWEEN 7 PRECEDING AND CURRENT ROW
    ) AS rolling_week_metric
  , SIZE(
      FILTER(
        SPLIT(tags, ','), 
        tag -> tag LIKE '%flag%'
      )
    ) AS flag_count
  , MAP_KEYS(attributes)[0] AS first_attr
  , CASE 
      WHEN custom_udf(score) > threshold THEN 'HIGH' 
      ELSE 'LOW' 
    END AS score_category
FROM source_table
LATERAL VIEW EXPLODE(nested_array) AS exploded_element
WHERE
  event_time >= DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 30 DAYS)
  AND EXTRACT(YEAR FROM event_time) = YEAR(CURRENT_TIMESTAMP)
GROUP BY
  user_id
  , event_date
  , event_day
  , exploded_element
  , first_attr
  , score_category
HAVING SUM(metric) > 0
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY user_id, event_day 
  ORDER BY metric DESC
) = 1
"""

hive_sql = sqlglot.transpile(impala_sql, read='impala', write='hive')[0]
print(hive_sql)
