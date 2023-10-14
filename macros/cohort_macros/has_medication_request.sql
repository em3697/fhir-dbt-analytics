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


{% macro has_medication_request(medication, code_system=None, lookback=None, patient_join_key= None, return_all= FALSE) -%}
  {%- if return_all == TRUE %}
  (SELECT
  (SELECT AS STRUCT
      MR.subject.patientid AS patient_id, 
      LOWER('{{medication}}') AS medication_group,
      {{ get_medication('text') }} AS medication_free_text_name,
      {{ get_medication('code',code_system) }} AS medication_code,
      {{ metric_date(['authoredOn']) }} AS authored_date,
  ) AS medication_request_struct
  {%- else -%}
  EXISTS (
    SELECT
      MR.subject.patientId
  {%- endif %}
  FROM {{ ref('MedicationRequest_view') }} AS MR
  JOIN {{ ref('clinical_code_groups') }} AS L
    ON L.group = '{{medication}}'
    {%- if code_system != None %}
    AND L.system {{ sql_comparison_expression(code_system) }}
    {%- endif %}
    AND IF(L.match_type = 'exact', 
           {{ get_medication('code',code_system) }} = L.code,
            FALSE) # No support for other match types

  WHERE TRUE
  {%- if patient_join_key != None %}
    AND patient_join_key = MR.subject.patientId
    {%- endif %}
  {%- if lookback != None %}
    AND {{ metric_date(['authored_on']) }} >= {{ get_snapshot_date() }} - INTERVAL {{ lookback }}
    {%- endif %}
    AND MR.status NOT IN ('entered-in-error','cancelled','draft')
  )
{%- endmacro %}