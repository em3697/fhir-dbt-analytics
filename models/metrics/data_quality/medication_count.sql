{#
/* Copyright 2022 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */
#}

{{ config(
    meta = {
      "description": "Count of valid Medication resources",
      "short_description": "Medication resources",
      "primary_resource": "Medication",
      "primary_fields": ['id'],
      "secondary_resources": [],
      "calculation": "COUNT",
      "category": "Resource count",
      "dimension_a_name": "Status",
      "dimension_a_description": "The status of the medication (active | inactive | entered-in-error)",
    }
) -}}

-- depends_on: {{ ref('Medication') }}
{%- if fhir_resource_exists('Medication') %}

WITH
  A AS (
    SELECT
      id,
      fhir_mapping,
      source_system,
      site,
      data_transfer_type,
      {{ get_column_or_default('status') }} AS status,
    FROM {{ ref('Medication') }}
  )
SELECT
  CURRENT_DATETIME() as execution_datetime,
  '{{this.name}}' AS metric_name,
  fhir_mapping AS fhir_mapping,
  source_system,
  data_transfer_type AS data_transfer_type,
  CAST(NULL AS DATE) AS metric_date,
  site,
  CAST(status AS STRING) AS slice_a,
  CAST(NULL AS STRING) AS slice_b,
  CAST(NULL AS STRING) AS slice_c,
  NULL AS numerator,
  COUNT(DISTINCT id) AS denominator_cohort,
  CAST(COUNT(DISTINCT id) AS FLOAT64) AS measure
FROM A
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

{%- else %}
{{- empty_metric_output() -}}
{%- endif -%}