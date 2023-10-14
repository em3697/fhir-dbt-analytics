-- Copyright 2023 Google LLC
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

{% macro has_procedure(procedure, code_system=None, lookback=None, patient_join_key= None, return_all= FALSE) -%}
  {%- if return_all == TRUE %}
  (SELECT
  (SELECT AS STRUCT
      P.subject.patientid AS patient_id,
      P.encounter.encounterId, 
      LOWER('{{procedure}}') AS procedure_group,
      P.code.text AS procedure_name,
      cc.code AS procedure_code,
      COALESCE({{ metric_date(['performed.dateTime']) }}, {{ metric_date(['performed.period.start']) }}) AS performed_date,
  ) AS procedure_struct
  {%- else -%}
  EXISTS (
    SELECT
      P.subject.patientId
  {%- endif %}
  FROM {{ ref('Procedure_view') }} AS P, UNNEST(code.coding) AS cc
  JOIN {{ ref('clinical_code_groups') }} AS L
    ON L.group = '{{procedure}}'
    {%- if code_system != None %}
    AND L.system {{ sql_comparison_expression(code_system) }}
    {%- endif %}
    AND cc.system = L.system
    AND IF(L.match_type = 'exact', 
           cc.code = L.code,
            FALSE) # No support for other match types
  
  WHERE TRUE
  {%- if patient_join_key != None %}
    AND patient_join_key = P.subject.patientId
    {%- endif %}
  {%- if lookback != None %}
    AND COALESCE({{ metric_date(['performed.dateTime']) }}, 
                 {{ metric_date(['performed.period.start']) }}) >= {{ get_snapshot_date() }} - INTERVAL {{ lookback }}
    {%- endif %}
    AND P.status NOT IN ('entered-in-error','not-done')
  )
{%- endmacro %}