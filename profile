PATH="$PATH:$HOME/.openstack/bin:$HOME/.buildvm"

alias openstack_login="source ~/limestone-openrc"

function setproject {
  local NEWPROJ=$1
  export OS_TENANT_NAME="${NEWPROJ}"
  export OS_PROJECT_NAME="${NEWPROJ}"
}

cd ~
source limestone-openrc
