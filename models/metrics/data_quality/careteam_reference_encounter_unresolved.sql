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
      "description": "Proportion of CareTeam resources that reference a non-existent encounter",
      "short_description": "CareTeam ref. Enc - non-exist",
      "primary_resource": "CareTeam",
      "primary_fields": ['encounter.encounterId'],
      "secondary_resources": ['Encounter'],
      "calculation": "PROPORTION",
      "category": "Referential integrity",
      "metric_date_field": "CareTeam.period.start",
      "metric_date_description": "Start of time period covered by care team",
      "dimension_a": "status",
      "dimension_a_description": "The status of the care team (proposed | active | suspended | inactive | entered-in-error)",
    }
) -}}

{%- set metric_sql -%}
    SELECT
      C.id,
      {{- metric_common_dimensions() }}
      {{ get_column_or_default('status') }} AS status,
      {{ has_reference_value('encounter', 'Encounter') }} AS has_reference_value,
      {{ reference_resolves('encounter', 'Encounter') }} AS reference_resolves
    FROM {{ ref('CareTeam') }} AS C
{%- endset -%}

{{ calculate_metric(
    metric_sql,
    numerator = 'SUM(has_reference_value - reference_resolves)',
    denominator = 'COUNT(id)'
) }}
