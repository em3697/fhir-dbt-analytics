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
      "description": "Count of valid EpisodeOfCare resources",
      "short_description": "EpisodeOfCare resources",
      "primary_resource": "EpisodeOfCare",
      "primary_fields": ['id'],
      "secondary_resources": [],
      "calculation": "COUNT",
      "category": "Resource count",
      "metric_date_field": "EpisodeOfCare.period.start",
      "metric_date_description": "EpisodeOfCare start date",
      "dimension_a": "status",
      "dimension_a_description": "The status of the EpisodeOfCare (planned | waitlist | active | onhold | finished | cancelled | entered-in-error)",
      "dimension_b": "type",
      "dimension_b_description": "The type of the EpisodeOfCare",
    }
) -}}

{%- set metric_sql -%}
    SELECT
      id,
      {{- metric_common_dimensions() }}
      status,
      {{ fhir_dbt_utils.code_from_codeableconcept('type', 'http://hl7.org/fhir/ValueSet/episodeofcare-type') }} AS type
    FROM {{ ref('EpisodeOfCare') }}
{%- endset -%}

{{ calculate_metric(metric_sql) }}