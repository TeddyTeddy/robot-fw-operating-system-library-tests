*** Settings ***
Documentation    This Suite will create & delete directories under Artifacts folder
Library          OperatingSystem
Variables        ../Libraries/common_variables.py
Suite Setup      Suite Setup

*** Variables ***
${PROJECT_FULL_PATH}
${WAIT_FOR_ME}
${DELETE_ME}
${ARTIFACTS_DIR} =   Artifacts/
${SYSTEM}

*** Keywords ***
Suite Setup
    ${system}=    Evaluate    expression=platform.system()     modules=platform
    Set Suite Variable      ${SYSTEM}       ${system}

    ${project_full_path} =   Run     ${COMMANDS}[${SYSTEM}][get_project_full_path]
    Set Suite Variable  ${PROJECT_FULL_PATH}    ${project_full_path}

    ${artifacts_dir_full_path} =  Join Path   ${PROJECT_FULL_PATH}    ${ARTIFACTS_DIR}
    Create Directory    ${artifacts_dir_full_path}       # does nothing if the folder already exists
    Set Suite Variable  ${ARTIFACTS_DIR_FULL_PATH}  ${artifacts_dir_full_path}

    ${wait_for_me} =    Join Path   ${ARTIFACTS_DIR_FULL_PATH}      wait_for_me
    Set Suite Variable   ${WAIT_FOR_ME}    ${wait_for_me}
    Set Suite Variable   ${DELETE_ME}      ${wait_for_me}

    Remove Directory    ${DELETE_ME}    recursive=${True}

*** Test Cases ***
Create Directory "Wait For Me" Under "Artifacts" Folder
    Sleep   time_=5s
    Create Directory    ${WAIT_FOR_ME}  # Refer to operating-system-library-tests.robot, Use "Wait Until Created"

Delete Directory "Wait For Me" Under "Artifacts" Folder
    Sleep   time_=5s
    # Refer to operating-system-library-tests.robot, Use "Wait Until Removed"
    Remove Directory    ${DELETE_ME}    recursive=${True}






