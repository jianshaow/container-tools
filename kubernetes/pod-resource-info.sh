#!/bin/bash

if [ ! -f "env.sh" ]; then
  echo an env.sh needed, refer to example
  exit 1
fi

. env.sh
. pod-common.sh

pod_split_line='----------------------------------------------------------------------------'
deploy_split_line='================================================================================'
resource_jsonpath='{.name}{":\n\tlimits:"}{.resources.limits}{"\n\trequests:"}{.resources.requests}{"\n"}'
pod_title='{"'$pod_split_line'\npod: "}'

print_pod_resources_by_name() {
  pod_name=$1

  kubectl -n $ns get po $pod_name -ojsonpath="$pod_title"'{.metadata.name}{"\n'$pod_split_line'\n"}{range .spec.containers[*]}'$resource_jsonpath'{end}'
}

print_pod_resources_by_label() {
  pod_label=$1
  all_flag=$2


 if [ "$all_flag" == "--all" ]; then
   kubectl -n $ns get po -l $pod_label -ojsonpath='{range .items[*]}'"$pod_title"'{.metadata.name}{"\n'$pod_split_line'\n"}{range .spec.containers[*]}'$resource_jsonpath'{end}{end}'
 else
   kubectl -n $ns get po -l $pod_label -ojsonpath="$pod_title"'{.items[0].metadata.name}{"\n'$pod_split_line'\n"}{range .items[0].spec.containers[*]}'$resource_jsonpath'{end}'
 fi
}

print_pod_resources_of_workload() {
  workload=$1
  if [ "$2" == "--all" ]; then
    all_flag=$2
  else
    workload_label=$2
    all_flag=$3
  fi

  if [ "$workload_label" != "" ]; then
    label_args="-l $workload_label"
  fi

  kubectl -n $ns get $workload --no-headers $label_args -ojsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | xargs -I {} bash -c "echo $deploy_split_line; echo $workload: {}; echo $deploy_split_line; ./pod-resource-info.sh -a {} $all_flag"
}

usage () {
  echo "Usage: `basename $0` [ [-d|-s|--daemonset] <label>|-a <app_name>|-p <pod>]"
  echo
  return 2
}

case $1 in
  -d)
    print_pod_resources_of_workload deployment $2 $3
    ;;
  -s)
    print_pod_resources_of_workload statefulset $2 $3
    ;;
  --daemonset)
    print_pod_resources_of_workload daemonset $2 $3
    ;;
  -a)
    print_pod_resources_by_label $app_name_label=$2 $3
    ;;
  -p)
    print_pod_resources_by_name $2
    ;;
  *)
    usage
    ;;
esac
