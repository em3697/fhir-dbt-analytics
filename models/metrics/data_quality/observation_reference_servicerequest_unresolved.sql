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
      "description": "Proportion of Observation resources that reference a non-existent service request",
      "short_description": "Obs ref. SerReq - non-exist",
      "primary_resource": "Observation",
      "primary_fields": ['encounter.encounterId'],
      "secondary_resources": ['ServiceRequest'],
      "calculation": "PROPORTION",
      "category": "Referential integrity",
      "metric_date_field": "Observation.effective.dateTime",
      "metric_date_description": "Observation effective date",
      "dimension_a": "status",
      "dimension_a_description": "The status of the observation (registered | preliminary | final | amended +)",
    }
) -}}

{%- set metric_sql -%}
    SELECT
      id,
      {{- metric_common_dimensions() }}
      status,
      (
        SELECT SIGN(COUNT(*))
        FROM UNNEST(O.basedOn) AS OB
        WHERE serviceRequestId IS NOT NULL AND serviceRequestId <> ''
      ) AS has_reference_servicerequest,
      (
        SELECT SIGN(COUNT(*))
        FROM UNNEST(O.basedOn) AS OB
        JOIN {{ ref('ServiceRequest') }} AS S
          ON OB.serviceRequestId = S.id
      ) AS reference_servicerequest_resolved
    FROM {{ ref('Observation') }} AS O
{%- endset -%}

{{ calculate_metric(
    metric_sql,
    numerator = 'SUM(has_reference_servicerequest - reference_servicerequest_resolved)',
    denominator = 'COUNT(id)'
) }}
