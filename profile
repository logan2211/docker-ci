PATH="$PATH:$HOME/.openstack/bin:$HOME/.buildvm"

alias openstack_login="source ~/limestone-openrc"

function setproject {
  local NEWPROJ=$1
  export OS_TENANT_NAME="${NEWPROJ}"
  export OS_PROJECT_NAME="${NEWPROJ}"
  local PROJID=$(openstack project show -f value -c id ${1})
  local EC2=$(openstack ec2 credentials list -f value -c Access -c Secret -c 'Project ID' | grep ${PROJID} | head -n1)
  if [[ ! -z "$EC2" ]]; then
    export AWS_ACCESS_KEY_ID=$(echo ${EC2} | awk '{ print $1 }')
    export AWS_SECRET_ACCESS_KEY=$(echo ${EC2} | awk '{ print $2 }')
  fi
}

cd ~
source limestone-openrc
