## Macro to add scene nodes for an extension.
## Usage: OE_ADD_SCENE_NODES(MyExtension Scene/Node1 Scene/Node2)
## Notice that the nodes do not have file endings (.h or .cpp)!
MACRO(OE_ADD_SCENE_NODES ext)
  # Nodes are in ${ARGN}
  FOREACH(NODE ${ARGN})
    SET(OE_SCENE_NODE_NODES ${OE_SCENE_NODE_NODES} "${OE_CURRENT_EXTENSION_DIR}/${NODE}")
  ENDFOREACH(NODE)
  SET(OE_SCENE_NODE_EXTENSIONS ${OE_SCENE_NODE_EXTENSIONS} ${ext})
ENDMACRO(OE_ADD_SCENE_NODES)

## --------------------------------------------------

## Internal special variables (not for use outside this file!)
SET(OE_SCENE_NODE_NODES "")
SET(OE_SCENE_NODE_EXTENSIONS "")
SET(OE_SCENE_NODE_XMACRO_EXPANSION "")
SET(OE_SCENE_NODE_INCLUDE_EXPANSION "")

## This file is not an auto generated file!
SET(OE_AUTOGEN_HEADER_TPL 
"// -------------------------------------------------------------------
// NOTICE:
// This file has been auto generated by the CMake system.
// All modifications should be done in \@TEMPLATE_FILE_NAME\@
// -------------------------------------------------------------------
// ALL MODIFICATIONS TO THIS FILE WILL BE LOST NEXT TIME YOU REBUILD.
// -------------------------------------------------------------------")

## --------------------------------------------------
## EXTENSION LINKING
## --------------------------------------------------

# Find all sub directories in the extensions directory
FILE(GLOB EXTENSIONS_SUB_DIRECTORIES RELATIVE
     ${OE_EXTENSIONS_DIR} "${OE_EXTENSIONS_DIR}/*")

# If any extensions are found include them
FOREACH(SUB_DIR ${EXTENSIONS_SUB_DIRECTORIES})
  SET(FULL_SUB_DIR "${OE_EXTENSIONS_DIR}/${SUB_DIR}")
  IF(IS_DIRECTORY ${FULL_SUB_DIR})

    MESSAGE(STATUS "Linking in extension: ${SUB_DIR}")
    INCLUDE_DIRECTORIES(${FULL_SUB_DIR})
    SUBDIRS(${FULL_SUB_DIR})

    # Invoke setup file if present
    SET(SETUP_FILE "${FULL_SUB_DIR}/Setup.cmake")
    IF(EXISTS ${SETUP_FILE})
      SET(OE_CURRENT_EXTENSION_DIR "${FULL_SUB_DIR}")
      INCLUDE(${SETUP_FILE})
      SET(OE_CURRENT_EXTENSION_DIR "")
    ENDIF(EXISTS ${SETUP_FILE})

  ENDIF(IS_DIRECTORY ${FULL_SUB_DIR})
ENDFOREACH(SUB_DIR)

## --------------------------------------------------
## SCENE NODE GENERATION
## --------------------------------------------------

IF(OE_DEBUG_CMAKE)
  MESSAGE(STATUS "Setting up scene node extensions.")
ENDIF(OE_DEBUG_CMAKE)

FOREACH(NODE_PATH ${OE_SCENE_NODE_NODES})
  IF(OE_DEBUG_CMAKE)
    MESSAGE(STATUS "Performing sanity checks on line: ${NODE_PATH}")
  ENDIF(OE_DEBUG_CMAKE)

  # check variables
  STRING(REGEX MATCH   "^([a-zA-Z0-9/]*/Scene/[a-zA-Z][a-zA-Z0-9]*)$"   NODE_CHECK ${NODE_PATH})
  STRING(REGEX REPLACE "^([a-zA-Z0-9/]*)/([a-zA-Z][a-zA-Z0-9]*)$" "\\1" NODE_DIR   ${NODE_PATH})
  STRING(REGEX REPLACE "^([a-zA-Z0-9/]*)/([a-zA-Z][a-zA-Z0-9]*)$" "\\2" NODE       ${NODE_PATH})
  FIND_FILE(NODE_HEAD_FILE "${NODE}.h"   ${NODE_DIR})
  FIND_FILE(NODE_IMPL_FILE "${NODE}.cpp" ${NODE_DIR})

  # check format (Path/SomeNode)
  IF(NOT NODE_CHECK STREQUAL NODE_PATH)
    MESSAGE(SEND_ERROR "Invalid scene node '${NODE_PATH}'. New scene nodes must be located in the 'Scene' sub-directory.")

  # check that files exists
  ELSEIF(NOT NODE_HEAD_FILE)
    MESSAGE(SEND_ERROR "Could not find header for ${NODE} at ${NODE_DIR}/${NODE}.h")

  ELSEIF(NOT NODE_IMPL_FILE)
    MESSAGE(SEND_ERROR "Could not find implementation for ${NODE} at ${NODE_DIR}/${NODE}.cpp")

  ELSE(NOT NODE_CHECK STREQUAL NODE_PATH)

    IF(OE_DEBUG_CMAKE)
      MESSAGE(STATUS "Generating expansion for: ${NODE}")
    ENDIF(OE_DEBUG_CMAKE)

    # generate header and implementation code
    SET(OE_SCENE_NODE_XMACRO_EXPANSION
      "${OE_SCENE_NODE_XMACRO_EXPANSION}SCENE_NODE(${NODE})\n")
    SET(OE_SCENE_NODE_INCLUDE_EXPANSION
      "${OE_SCENE_NODE_INCLUDE_EXPANSION}#include <Scene/${NODE}.h>\n")

  ENDIF(NOT NODE_CHECK STREQUAL NODE_PATH)
  
ENDFOREACH(NODE_PATH)

## --------------------------------------------------
## SCENE NODE TEMPLATE FILE GENERATION
## --------------------------------------------------

SET(TEMPLATE_FILE_NAME "SceneNodes.def.tpl")
STRING(CONFIGURE ${OE_AUTOGEN_HEADER_TPL} OE_AUTOGEN_HEADER @ONLY)
CONFIGURE_FILE(${OE_SOURCE_DIR}/Scene/SceneNodes.def.tpl
               ${OE_SOURCE_DIR}/Scene/SceneNodes.def
               @ONLY)

SET(TEMPLATE_FILE_NAME "SceneNodes.h.tpl")
STRING(CONFIGURE ${OE_AUTOGEN_HEADER_TPL} OE_AUTOGEN_HEADER @ONLY)
CONFIGURE_FILE(${OE_SOURCE_DIR}/Scene/SceneNodes.h.tpl
               ${OE_SOURCE_DIR}/Scene/SceneNodes.h
               @ONLY)

## --------------------------------------------------
## PROJECT LINKING
## --------------------------------------------------

# Find all sub directories in the projects directory
FILE(GLOB PROJECTS_SUB_DIRECTORIES RELATIVE ${OE_PROJECTS_DIR} "${OE_PROJECTS_DIR}/*")
FILE(GLOB PROJECTS_SUB_FILES       RELATIVE ${OE_PROJECTS_DIR} "${OE_PROJECTS_DIR}/*.*")
IF(PROJECTS_SUB_FILES)
  LIST(REMOVE_ITEM PROJECTS_SUB_DIRECTORIES ${PROJECTS_SUB_FILES})
ENDIF(PROJECTS_SUB_FILES)

# If any projects are found include them
FOREACH(SUB_DIR ${PROJECTS_SUB_DIRECTORIES})
  MESSAGE(STATUS "Linking in project: ${SUB_DIR}")
  SUBDIRS("${OE_PROJECTS_DIR}/${SUB_DIR}")
ENDFOREACH(SUB_DIR)
