
with base as (

    select * 
    from {{ ref('stg_netsuite__currencies_tmp') }}

),

fields as (

    select
        /*
        The below macro is used to generate the correct SQL for package staging models. It takes a list of columns 
        that are expected/needed (staging_columns from dbt_salesforce_source/models/tmp/) and compares it with columns 
        in the source (source_columns from dbt_salesforce_source/macros/).
        For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
        */

        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_netsuite__currencies_tmp')),
                staging_columns=get_currencies_columns()
            )
        }}
        --The below script allows for pass through columns.
        {% if var('currencies_pass_through_columns') %}
        ,
        {{ var('currencies_pass_through_columns') | join (", ")}}

        {% endif %}
    from base
),

final as (
    
    select 
        currency_id,
        name,
        symbol,
        _fivetran_deleted,
        _fivetran_synced

        --The below script allows for pass through columns.
        {% if var('currencies_pass_through_columns') %}
        ,
        {{ var('currencies_pass_through_columns') | join (", ")}}

        {% endif %}

    from fields
)

select * 
from final
where not coalesce(_fivetran_deleted, false)
