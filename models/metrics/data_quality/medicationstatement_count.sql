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
      "description": "Count of valid MedicationStatement resources",
      "short_description": "MedicationStatement resources",
      "primary_resource": "MedicationStatement",
      "primary_fields": ['id'],
      "secondary_resources": [],
      "calculation": "COUNT",
      "category": "Resource count",
      "metric_date_field": "MedicationStatement.dateAsserted",
      "metric_date_description": "Medication statement asserted date",
      "dimension_a": "status",
      "dimension_a_description": "The status of the medication statement (active | completed | entered-in-error | intended | stopped | on-hold | unknown | not-taken)",
    }
) -}}

{%- set metric_sql -%}
    SELECT
      id,
      {{- metric_common_dimensions() }}
      status
    FROM {{ ref('MedicationStatement') }} M
{%- endset -%}

{{ calculate_metric(metric_sql) }}