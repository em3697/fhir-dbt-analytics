{% macro model_metadata(meta_key, model_name=this.name) %}
  {%- if execute -%}
    {% set model_id = "model." ~ project_name ~ "." ~ model_name %}
    {% do return( graph["nodes"][model_id]["meta"][meta_key] ) %}
  {%- endif -%}
{% endmacro %}