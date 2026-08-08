export vmid="$1"
export FCAR_FILES_PATH=/etc/pve/flatcar

source template_deploy.sh

#mv ${FCAR_FILES_PATH}/${vmid}.ign{,.bak}

rm ${FCAR_FILES_PATH}/${vmid}.ign

.${snippet_storage}/snippets/hook-fcar.sh ${vmid} pre-start
# cat ${FCAR_FILES_PATH}/${vmid}.ign
/usr/local/bin/flatcar-config-transpiler --pretty --strict --out-file ${FCAR_FILES_PATH}/${vmid}.ign --in-file ${FCAR_FILES_PATH}/${vmid}.yaml
