kube_dir=kubepods.slice
kube_cgroup_suffix=.slice
qos_class_prefix=kubepods-
container_dir_prefix=docker-
container_dir_suffix=.scope

get_pod_dir() {
  pod_uid=$1
  echo pod${pod_uid//\-/\_}
}

get_pod_dir_prefix() {
  qos_class_dir=$1
  echo ${qos_class_dir}-
}