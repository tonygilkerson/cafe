#!/bin/bash
# set -x # trace
set -e # exit when any command fails

tmpdir=".temp/external-charts-ace"

usage () {
    echo "USAGE: ${0##*/} [--chart-list external-charts.txt] [--output external-charts] [--chart <chart-name>]"
    echo "  [-l|--chart-list path] text file with list of external charts; one image per line comma separated <name,URL,version>."
    echo "  [-o|--output path] path to folder where charts will be saved"
    echo "  [-c|--chart chartName] the name of a chart to upgrade, if omitted all charts in the chart-list are upgraded"
    echo "  [-h|--help] Usage message"
}

remove_deps() {
  echo Start remove_deps...
  #
  # Store a local copy of dependencies then remove chart dependency list from all charts in the $dir folder
  #
  dir="${1%/}" # a chart dir without trailing slash

  echo Using chart dir ["$dir"]
  if [ -f "$dir"/requirements.yaml ]; then
    echo Remove dependencies from requirements.yaml
    yq e 'del(.dependencies[].repository)' "$dir"/requirements.yaml  --inplace
    rm "$dir"/requirements.lock || true
  else
    echo Remove dependencies from Chart.yaml
    yq e 'del(.dependencies[].repository)' "$dir"/Chart.yaml  --inplace
    rm "$dir"/Chart.lock || true
  fi

  # rebuild lock file without reference to external dependency url
  # this is needed for air-gap environments 
  helm dependency build "$dir" --skip-refresh

  # Recursively remove dependency list from each chart located in the charts folder
  if [ -d "$dir"/charts ]; then
    for d in "$dir"/charts/*/; do
        echo Recursively process "$d"
        remove_deps "$d"
    done
  fi
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -o|--output)
        outdir="$2"
        shift # past argument
        shift # past value
        ;;
        -l|--chart-list)
        list="$2"
        shift # past argument
        shift # past value
        ;;
        -c|--chart)
        chart="$2"
        shift # past argument
        shift # past value
        ;;
        -h|--help)
        help="true"
        shift
        ;;
        *)
        usage
        exit 1
        ;;
    esac
done

if [[ $help ]]; then
    usage
    exit 0
fi

#
# First pass - do a "helm repo add" for each repo in the list
#
printf "\n\nFirst pass - do a 'helm repo add' for each repo in the list\n\n"
while IFS= read -r l; do
  # Skip comments or empty lines
  if [[ "$l" =~ ^(.*)\# ]] || [[ -z "$l" ]];then continue; fi
  name=$(echo "$l" | cut -d ',' -f 1)
  url=$(echo "$l" | cut -d ',' -f 2)
  version=$(echo "$l" | cut -d ',' -f 3)

  # Skip OCI registries
  if [[ "$url" == oci* ]]; then continue; fi

  echo Add/remove Repo:"$name", URL:"$url", Version: "$version"
  helm repo remove "$name" || true
  helm repo add "$name" "$url"

done < "${list}"

# The "helm pull" command will fail if the repo for its dependencies does not exist. 
printf "\n\nDo 'helm repo update' to update all that were just added...\n\n"
helm repo add grafana https://grafana.github.io/helm-charts          # Needed for kube-prometheus-stack

# Do this once after all the adds because it is slow
helm repo update

#
# Second pass - pull the charts and save locally
#
printf "\n\nSecond pass - pull the charts and save locally...\n\n"
while IFS= read -r l; do
  #
  # Skip comments or empty lines
  #
  if [[ "$l" =~ ^(.*)\# ]] || [[ -z "$l" ]];then continue; fi

  name=$(echo "$l" | cut -d ',' -f 1)
  url=$(echo "$l" | cut -d ',' -f 2)
  version=$(echo "$l" | cut -d ',' -f 3)

  #
  # if chart is specified then only name=chart is upgraded
  # if chart is not set then all items in the list are upgraded
  #
  if [ -n "$chart" ] && [ "$name" != "$chart" ]; then continue; fi

  echo "Pull... Repo: $name, URL: $url, Version: $version"
  echo "Using outdir: $outdir" 

  # Remove chart folder before pulling from internet
  rm -rf "${outdir:?}"/"${name}"
  
  if [[ "$url" == oci* ]]; then 
    helm pull "$url" --version "$version" --untar --untardir "$outdir"
  else
    helm pull "$name/$name" --version "$version" --untar --untardir "$outdir"

    # Build out the sub-chart dependencies by pulling from internet
    helm dependency build "$outdir"/"$name" --skip-refresh

    # Store a local copy of dependencies then remove the chart dependency list from all local charts
    remove_deps "$outdir/$name" 
  fi

  # clean up
  find "$outdir" -type f -name "*.tgz"  -exec rm {} \;
  
done < "${list}"

echo Done.
