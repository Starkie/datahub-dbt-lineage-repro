with all_articles as (
    select 
        articles.id,
        articles.article_name,
        articles.price   
    from {{ source("lineage_repro", "articles_landing") }} as articles
)

{# Option 1: Deduplicate macro #}
{#
{{
    dbt_utils.deduplicate(
        relation="all_articles",
        partition_by="id",
        order_by="article_name desc",
    )
}}
#}

{# Option 2: SQL generated by the deduplicate macro #}
select unique.*
from (
     select
         array_agg (
                 original
                     order by article_name desc
            limit 1
         )[offset(0)] unique
     from all_articles original
     group by id
)