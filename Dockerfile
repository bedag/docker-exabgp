
#
# Copyright © 2021 Bedag Informatik AG
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
FROM {{ build.image }} AS build
LABEL  \{% for tag in _dest['tags']|list %}
  "tag.{{ tag }}.repository"="{{ _dest['namespace'] }}/{{ _dest['name'] }}" \
  "tag.{{ tag }}.source"="{{ _source["name"] }}:{{ _source["tag"] }}" \
  "tag.{{ tag }}.git.repo"="{{ git_repo }}" \
  "tag.{{ tag }}.git.ref"="{{ git_ref }}" \
  "tag.{{ tag }}.git.commit"="{{ git_commit }}" \
{%- endfor %}
  "maintainer"="{{ maintainer }}" 

RUN apt update && apt install python3-venv gcc libpython3-dev git  -y \ 
    && git clone -b {{ major }}.{{ minor }}.{{ patch }} https://github.com/Exa-Networks/exabgp.git /app \
    && cd /app \
    && python3 -m venv /venv \ 
    && /venv/bin/pip install --force-reinstall --no-cache-dir --compile ./ 

FROM {{ _source["name"] }}:{{ _source["tag"] }}
COPY --from=build /venv /venv
ENTRYPOINT ["/venv/bin/python3"]
CMD ["/venv/bin/exabgp"] 
