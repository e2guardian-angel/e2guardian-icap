#!/bin/sh
GUARDIAN_CONF=/opt/guardian/guardian.json
CONFIG="$(cat $GUARDIAN_CONF)"
#E2G_ROOT=/opt/e2guardian/etc/e2guardian
E2G_GROUP=guardian.angel
E2G_GROUP_DIR=${E2G_ROOT}/lists/${E2G_GROUP}

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
    for PHRASELIST in ${1}; do
	FILENAME=${E2G_ROOT}/lists/${E2G_GROUP}/$(extract_value "${PHRASELIST}" listName)
	# Delete existing file
	rm -f ${FILENAME}
	for PHRASE in $(extract_value_compact "${PHRASELIST}" phrases); do
	    PHRASELINE=""
	    for TERM in $(echo "${PHRASE}" | jq -c .[]); do
		PHRASELINE="${PHRASELINE}<${TERM}> "
	    done
	    PHRASELINE=$(echo "${PHRASELINE}" | xargs | tr ' ' ,)
	    echo ${PHRASELINE} >> ${FILENAME}
	done
    done
}

generate_list() {
    for LIST in ${1}; do
	LISTNAME=$(extract_value "${LIST}" listName)
	FILENAME=${E2G_ROOT}/lists/${E2G_GROUP}/${LISTNAME}
	rm -f ${FILENAME}
	for ELEMENT in $(extract_value_compact "${LIST}" ${2}); do
	    remove_quotes ${ELEMENT} >> ${FILENAME}
	done
    done
}

if [ -f "${GUARDIAN_CONF}" ]; then
    E2G_CONF=$(extract_value "${CONFIG}" e2guardianConf)
    PHRASELISTS=$(extract_value_compact "${E2G_CONF}" phraseLists)
    SITELISTS=$(extract_value_compact "${E2G_CONF}" siteLists)
    REGEXPURLLISTS=$(extract_value_compact "${E2G_CONF}" regexpurllists)
    MIMETYPELISTS=$(extract_value_compact "${E2G_CONF}" mimetypelists)
    EXTENSIONSLISTS=$(extract_value_compact "${E2G_CONF}" extensionsLists)
    mkdir -p ${E2G_GROUP_DIR}

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
fi
