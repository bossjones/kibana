#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( */ )
versions=( "${versions[@]%/}" )

downloadable="$(curl -sSL 'https://www.elastic.co/downloads/past-releases' | sed -rn 's!.*?/downloads/past-releases/(kibana-)?[0-9]+-[0-9]+-[0-9]+">Kibana ([0-9]+\.[0-9]+\.[0-9]+)<.*!\2!gp')"

for version in "${versions[@]}"; do
	fullVersion="$(echo "$downloadable" | grep -m1 "^$version")"
	sha1="$(curl -fsSL "https://download.elastic.co/kibana/kibana/kibana-$fullVersion-linux-x64.tar.gz.sha1.txt" | cut -d' ' -f1)"

	(
		set -x
		sed -ri '
			s/^(ENV KIBANA_VERSION) .*/\1 '"$fullVersion"'/;
			s/^(ENV KIBANA_SHA1) .*/\1 '"$sha1"'/;
		' "$version/Dockerfile"
	)
done
