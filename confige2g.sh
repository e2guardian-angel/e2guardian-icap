#!/bin/sh
GUARDIAN_CONF=/opt/guardian/guardian.json
CONFIG="$(cat $GUARDIAN_CONF)"
E2G_GROUP=guardian.angel
E2G_GROUP_DIR=${E2G_ROOT}/lists/${E2G_GROUP}
# Set E2G_ROOT to the root of the e2guardian configuration (i.e. /etc/e2guardian)

extract_value () {
    echo "${1}" | jq -r .${2}
}

extract_value_compact () {
    extract_value "${1}" ${2} | jq -c '.[]'
}

remove_quotes () {
    echo ${1} | sed -e 's/^"//' -e 's/"$//'
}

generate_phrase_list() {
    if [ ! "${1}" ]; then
	return
    fi
    for PHRASELIST in "${1}"; do
	FILENAME=${E2G_ROOT}/lists/${E2G_GROUP}/$(extract_value "${PHRASELIST}" listName)
	# Delete existing file
	rm -f ${FILENAME}
	IFS="
	"
	for GROUP in $(extract_value_compact "${PHRASELIST}" groups); do
	    GROUPNAME=$(extract_value "${GROUP}" groupName)
	    echo "#listcategory: \"${GROUPNAME}\"" >> ${FILENAME}
	    for PHRASE in $(extract_value_compact "${GROUP}" phrases); do
		PHRASELINE=""
		for TERM in $(echo "${PHRASE}" | jq -c .[]); do
		    PHRASELINE="${PHRASELINE}<${TERM}> "
		done
		PHRASELINE=$(echo "${PHRASELINE}" | xargs | tr ' ' ,)
		echo ${PHRASELINE} >> ${FILENAME}
	    done
	done
    done
}

generate_list() {
    if [ ! "${1}" ]; then
	return
    fi
    for LIST in "${1}"; do
	LISTNAME=$(extract_value "${LIST}" listName)
	FILENAME=${E2G_ROOT}/lists/${E2G_GROUP}/${LISTNAME}
	rm -f ${FILENAME}
	IFS="
	"
	for GROUP in $(extract_value_compact "${LIST}" groups); do
	    GROUPNAME=$(extract_value "${GROUP}" groupName)
	    echo "#listcategory: \"${GROUPNAME}\"" >> ${FILENAME}
	    for ELEMENT in $(extract_value_compact "${GROUP}" ${2}); do
		remove_quotes ${ELEMENT} >> ${FILENAME}
	    done
	done
    done
}

# Restore original
E2GUARDIANF1=${E2G_ROOT}/e2guardianf1.conf
cp ${E2GUARDIANF1}.mod ${E2GUARDIANF1}

if [ -f "${GUARDIAN_CONF}" ]; then
    E2G_CONF=$(extract_value "${CONFIG}" e2guardianConf)
    PHRASELISTS=$(extract_value_compact "${E2G_CONF}" phraseLists)
    SITELISTS=$(extract_value_compact "${E2G_CONF}" siteLists)
    REGEXPURLLISTS=$(extract_value_compact "${E2G_CONF}" regexpurllists)
    MIMETYPELISTS=$(extract_value_compact "${E2G_CONF}" mimetypelists)
    EXTENSIONSLISTS=$(extract_value_compact "${E2G_CONF}" extensionslists)
    cp -r ${E2G_ROOT}/lists/example.group ${E2G_GROUP_DIR}

    # Generate phrase lists
    generate_phrase_list "${PHRASELISTS}"

    # Generate site lists
    generate_list "${SITELISTS}" sites

    # Generate regexpurllists
    generate_list "${REGEXPURLLISTS}" patterns

    # Generate mimetype lists
    generate_list "${MIMETYPELISTS}" types

    # Generate extension lists
    generate_list "${EXTENSIONSLISTS}" extensions

    # Configure e2guardianf1.conf
    E2GUARDIANF1=${E2G_ROOT}/e2guardianf1.conf
    DEFINELINE=".Define LISTDIR <${E2G_GROUP_DIR}>"
    # Replace the .Define line to point to our group
    sed -i "s~^\.Define.*~${DEFINELINE}~g" ${E2GUARDIANF1}
fi
