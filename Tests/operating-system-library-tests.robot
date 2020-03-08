*** Settings ***
Documentation    Test cases for keywords in OS library
Library          OperatingSystem
Variables        ../Libraries/common_variables.py
Suite Setup      Suite Setup

*** Variables ***
${PROJECT_FULL_PATH}
${PATH_TO_TRASH}
${ARTIFACTS_DIR} =   Artifacts/
${ARTIFACTS_DIR_FULL_PATH}
${DESTINATION_DIR} =    Copy/Here/
${ANOTHER_DESTINATION_DIR} =    Copy2/Here/
${DESTINATION_DIR_FULL_PATH}
${ANOTHER_DESTINATION_DIR_FULL_PATH}
${PATH_TO_CRAZY_MILO}
${TARGET_PATH}
${EMPTY_DIR} =  Empty/
${WAIT_FOR_ME}
${SYSTEM}

# To Run:
# pabot --pythonpath Resources --noncritical failure-expected -d Results/ Tests/

*** Keywords ***
Suite Setup
    ${system}=    Evaluate    expression=platform.system()     modules=platform
    Set Suite Variable      ${SYSTEM}       ${system}

    ${project_full_path} =   Run     ${COMMANDS}[${SYSTEM}][get_project_full_path]
    Set Suite Variable  ${PROJECT_FULL_PATH}    ${project_full_path}

    ${artifacts_dir_full_path} =  Join Path   ${PROJECT_FULL_PATH}    ${ARTIFACTS_DIR}
    Create Directory    ${artifacts_dir_full_path}       # does nothing if the folder already exists
    Set Suite Variable  ${ARTIFACTS_DIR_FULL_PATH}  ${artifacts_dir_full_path}

    ${path_to_trash} =  Join Path    ${ARTIFACTS_DIR_FULL_PATH}    Trash
    Empty Directory     ${path_to_trash}
    set suite variable  ${PATH_TO_TRASH}    ${path_to_trash}

    ${destination_dir_full_path} =  Join Path   ${PROJECT_FULL_PATH}    ${DESTINATION_DIR}
    ${command} =    Catenate   rm -rf  ${destination_dir_full_path}   # by default items are catenated with spaces
    Run   ${command}        # Delete ${DESTINATION_DIR} (i.e. i.e. Copy/Here/ )
    Set Suite Variable  ${DESTINATION_DIR_FULL_PATH}    ${destination_dir_full_path}

    ${destination_dir_full_path} =  Join Path   ${PROJECT_FULL_PATH}    ${ANOTHER_DESTINATION_DIR}
    ${command} =    Catenate   rm -rf  ${destination_dir_full_path}   # by default items are catenated with spaces
    Run   ${command}        # Delete ${DESTINATION_DIR} (i.e. i.e. Copy/Here/ )
    Set Suite Variable  ${ANOTHER_DESTINATION_DIR_FULL_PATH}    ${destination_dir_full_path}

    ${wait_for_me} =    Join Path   ${ARTIFACTS_DIR_FULL_PATH}      wait_for_me
    Set Suite Variable   ${WAIT_FOR_ME}    ${wait_for_me}

Do Create File
    [Documentation]  Creates a file named file_name under target_path with a given file_content
    [Arguments]     ${target_path}     ${file_name}    ${file_content}
    Create File    path=${target_path}${/}${filename}      content=${file_content}  encoding=UTF-8    # possible existing file is overwritten
    [return]  ${target_path}${/}${filename}

*** Test Cases ***
Use "Append To Environment Variable"
    [Documentation]   Note that the env variables created/modified are only available during test suite execution
    ...               (i.e. go to command prompt after you run the test case, and type echo $ENV_VAR; you get empty string

    # If the environment variable already exists, values are added after it, and otherwise a new environment variable is created.
    Append To Environment Variable 	    ENV_VAR 	first
    Should Be Equal 	%{ENV_VAR} 	    first
    Append To Environment Variable 	    ENV_VAR 	second 	third
    Should Be Equal 	%{ENV_VAR} 	    first${:}second${:}third

    Append To Environment Variable 	    ENV_VAR2 	first 	separator=-
    Should Be Equal 	%{ENV_VAR2} 	first 	
    Append To Environment Variable 	    ENV_VAR2 	second 	separator=-
    Should Be Equal 	%{ENV_VAR2} 	first-second

Check If Env Var Created In Previous Test Case Exists In Test Suite
    Should Be Equal 	%{ENV_VAR} 	    first${:}second${:}third        # it does
    # OR
    Environment Variable Should Be Set      ENV_VAR

Use "Create File"
    # test
    Do Create File  target_path=${ARTIFACTS_DIR_FULL_PATH}  file_name=example_1.txt     file_content=3\nlines\nhere\n
    Do Create File  target_path=${ARTIFACTS_DIR_FULL_PATH}  file_name=example_2.txt     file_content=4\nlines\nhere\nindeed\n

Use "Append To File"
    [Documentation]  Appends the given content to the specified file.
    ...              If the file exists, the given text is written to its end.
    ...              If the file does not exist, it is created.

    # setup
    # make sure that "brand_new_file.txt" does not exist
    ${file_name} =   Set Variable   brand_new_file.txt
    ${full_path_to_file} =   Join Path   ${ARTIFACTS_DIR_FULL_PATH}   ${file_name}
    Remove File     ${full_path_to_file}

    # test
    # Since the file indicated by ${full_path_to_file} does not exist, it is created.
    Append To File   path=${full_path_to_file}      content=First line\nSecond Line\n   encoding=UTF-8

    # we know that ${full_path_to_file} points at "brand_new_file.txt" under Artifacts folder
    # and the file exists. So, acc.to the documentation, if the file exists, the given text is written to its end
    Append To File   path=${full_path_to_file}      content=Third line\nFourth Line\n   encoding=UTF-8

Use "Copy Directory" To Copy The Items Under A Directory (But not the directory itself)
    [Documentation]    	Copies the source directory CONTENTS into the destination.
    ...                 If the destination exists, the source CONTENT is copied under it.
    ...                 Otherwise the destination directory
    ...                 and the possible missing intermediate directories are created.

    # note that in test suite setup, we made sure that the directory pointed by DESTINATION_DIR_FULL_PATH
    # is indeed deleted. So, the destination directory and the possible missing intermediate directories are created
    # note that only Artifacts/ folder's contents is copied to destination, not the Artifacts/ folder itself!
    # if Artifacts/ folder contains folders itself, then those folders will be copied into destination.
    Copy Directory      source=${ARTIFACTS_DIR_FULL_PATH}       destination=${DESTINATION_DIR_FULL_PATH}

Do Copy "Artifacts" Folder Under "Copy2/Here"
    [Documentation]     This test does effectly the same thing of the following; Ctrl+C on Artifacts/ and then
    ...                 Ctrl+V on Copy2/Here/. This means that Artifacts/ folder itself (and its contents) is
    ...                 copied under Copy2/Here
    ...                 You can copy the content of a folder /source to another existing folder /dest with the command
    ...                 cp -a /source/. /dest/
    ...                 The -a option is an improved recursive option, that preserve all file attributes, and also preserve symlinks.
    ...                 The . at end of the source path is a specific cp syntax that allow to copy all files and folders,
    ...                 including hidden ones.
    ${target_path}=     Join Path   ${ANOTHER_DESTINATION_DIR_FULL_PATH}    ${ARTIFACTS_DIR}
    Create Directory    path=${target_path}
    ${command} =    Catenate    cp -a   ${ARTIFACTS_DIR_FULL_PATH}${/}.     ${target_path}
    Run     ${command}

Use "Copy File"
    [Documentation]     Copy File 	source, destination
    ...                 Copies the source file into the destination.
    ...                 Source must be a path to an existing file or a glob pattern (see Pattern matching)
    ...                 that matches exactly one file.How the destination is interpreted is explained below:
    # note that we ran rm -rf Copy/Here/ at test suite setup; removing here/ folder
    # setup
    ${source_file_path} =       Join Path   ${ARTIFACTS_DIR_FULL_PATH}      example_1.txt
    ${existing_dest_file} =     Join Path   ${DESTINATION_DIR_FULL_PATH}    example_1.txt
    ${non_existing_directory} =     Catenate   ${DESTINATION_DIR_FULL_PATH}${/}new${/}folder${/}
    ${non_existing_file} =          Catenate   ${DESTINATION_DIR_FULL_PATH}${/}new${/}folder${/}non-existing-file.txt


    # test: If the destination is an existing file, the source file is copied over it.
    Copy File     source=${source_file_path}    destination=${existing_dest_file}

    # test: If the destination is an existing directory, the source file is copied into it.
    # A possible file with the same name as the source is overwritten.
    Copy File     source=${source_file_path}    destination=${DESTINATION_DIR_FULL_PATH}

    # test: If the destination does not exist and it ends with a path separator (/ or \), it is considered a directory.
    # That directory is created and a source file copied into it. Possible missing intermediate directories are also created
    Copy File     source=${source_file_path}    destination=${non_existing_directory}

    # 4) If the destination does not exist and it does not end with a path separator, it is considered a file.
    # If the path to the file does not exist, it is created
    Copy File     source=${source_file_path}    destination=${non_existing_file}

Use "Copy Files"
    [Documentation]  Last argument must be the destination directory. If the destination does not exist,
    ...              it will be created.
    # (1) and (2) does the same thing
    Copy Files    ${ARTIFACTS_DIR_FULL_PATH}${/}example_?.txt   ${DESTINATION_DIR_FULL_PATH}    # (1)
    Copy Files    ${ARTIFACTS_DIR_FULL_PATH}${/}example_1.txt  ${ARTIFACTS_DIR_FULL_PATH}${/}example_2.txt  ${DESTINATION_DIR_FULL_PATH}  # (2)

Use "Count Directories In Directory"
    [Documentation]     This test case uses bash commands to count the number of directories in this project's root directory
    ...                 (i.e. robot-fw-operating-system-library-tests/ )
    ...
    ...                 The # of directories calculated this way is compared againist the output of "Count Directories In Directory"
    ...                 keyword. We pass project the project's full path to the keyword
    ...

    # test
    ${dir_count} =  Count Directories In Directory    path=${PROJECT_FULL_PATH}
    # verify based on the platform
    ${linux_command} =    Catenate    ls -la ${PROJECT_FULL_PATH} | grep -v ^- | grep -v ^total | grep -v ^l | grep -v '\\.$' | wc -l  # counting in the hidden .idea/ folder as well; ls -la
    ${windows_command} =    Catenate  dir /ad   "${PROJECT_FULL_PATH}"  | findstr /v /c:Directory /v /c:Volume /v /c:File(s) /v /c:Dir(s) | findstr /v /e /c:. | find /c "DIR"
    ${command} =    Run Keyword If  $SYSTEM=='Linux'      Set Variable    ${linux_command}
    ...             ELSE IF         $SYSTEM=='Windows'    Set Variable    ${windows_command}
    ...             ELSE            Fail    msg=Operating System Not Recognized
    ${expected_dir_count} =     Run  ${command}
    Should Be Equal As Integers     ${dir_count}        ${expected_dir_count}       # counting in the hidden .idea/ folder as well; ls -la

    # test: the use of pattern to look for both Resources/ and Results/ directories under ${PROJECT_FULL_PATH}
    ${dir_count} =  Count Directories In Directory    path=${PROJECT_FULL_PATH}   pattern=[rR]*s
    # verify based on the platform
    # https://stackoverflow.com/questions/28899349/find-lines-starting-with-one-specific-character-and-ending-with-another-one
    ${linux_command} =      Catenate    ls  ${PROJECT_FULL_PATH}     | grep '^R.*s$' | wc -l
    ${windows_command} =    Catenate    dir ${PROJECT_FULL_PATH}     /b /d | findstr /r /c:R.*s | find /v "" /c
    ${command} =    Run Keyword If  $SYSTEM=='Linux'      Set Variable    ${linux_command}
    ...             ELSE IF         $SYSTEM=='Windows'    Set Variable    ${windows_command}
    ...             ELSE            Fail    msg=Operating System Not Recognized
    ${expected_dir_count} =     Run  ${command}
    Should Be Equal As Integers     ${dir_count}        ${expected_dir_count}       # Results/

Use "Count Files In Directory"
    # test
    ${file_count} =  Count Files In Directory    path=${ARTIFACTS_DIR_FULL_PATH}
    # verify based on the platform
    ${linux_command} =    Catenate    ls -l ${ARTIFACTS_DIR_FULL_PATH} | grep -v ^d | grep -v ^total | grep -v ^l | wc -l
    ${windows_command} =  Catenate    dir ${ARTIFACTS_DIR_FULL_PATH} /b /a-d | find /v "" /c
    ${command} =    Run Keyword If  $SYSTEM=='Linux'      Set Variable    ${linux_command}
    ...             ELSE IF         $SYSTEM=='Windows'    Set Variable    ${windows_command}
    ...             ELSE            Fail    msg=Operating System Not Recognized
    ${expected_file_count} =    Run  ${command}
    Should Be Equal As Integers    ${file_count}    ${expected_file_count}

Use "Count Items In Directory"
    [Documentation]   This is the folder structure under Artifacts/
    ...               (base) hakan@hakan-VirtualBox:~/Python/Robot/robot-fw-operating-system-library-tests$ ls -la Artifacts/
    ...               total 24
    ...               drwxr-xr-x 3 hakan hakan 4096 helmi 27 14:15 .
    ...               drwxr-xr-x 8 hakan hakan 4096 helmi 27 09:54 ..
    ...               -rw-r--r-- 1 hakan hakan   46 helmi 27 14:15 brand_new_file.txt  <-- item
    ...               drwxrwxr-x 2 hakan hakan 4096 helmi 27 10:12 EmptyFolder         <-- item
    ...               -rw-r--r-- 1 hakan hakan   13 helmi 27 14:15 example_1.txt       <-- item
    ...               -rw-r--r-- 1 hakan hakan   20 helmi 27 14:15 example_2.txt       <-- item
    # test
    ${item_count} =     Count Items In Directory    path=${ARTIFACTS_DIR_FULL_PATH}
    # verify based on the platform
    ${linux_command} =        Catenate    ls  ${ARTIFACTS_DIR_FULL_PATH} | wc -l
    ${windows_command} =      Catenate    dir ${ARTIFACTS_DIR_FULL_PATH} /b | find /v "" /c
    ${command} =    Run Keyword If  $SYSTEM=='Linux'      Set Variable    ${linux_command}
    ...             ELSE IF         $SYSTEM=='Windows'    Set Variable    ${windows_command}
    ...             ELSE            Fail    msg=Operating System Not Recognized
    ${expected_number_of_items} =    Run     ${command}
    Should Be Equal As Integers      ${expected_number_of_items}    ${item_count}

Use "Create Binary File" To Create Milo Copy
    # setup
    ${path_to_crazy_milo} =     Join Path   ${ARTIFACTS_DIR_FULL_PATH}      CrazyMilo.jpeg
    ${content}=     Get Binary File     ${path_to_crazy_milo}       # reads the specified file and returns the contents as is
    ${path_to_crazy_milo_copy} =    Join Path   ${ARTIFACTS_DIR_FULL_PATH}      CrazyMilo(Copy).jpeg

    # test
    Create Binary File      path=${path_to_crazy_milo_copy}     content=${content}

    # for the next test cases
    Set Suite Variable   ${PATH_TO_CRAZY_MILO}    ${path_to_crazy_milo}

Use "Create Directory"
    # note that in suite setup, we delete the contents of ${DESTINATION_DIR_FULL_PATH}
    # so the following ${target_path} does not exist
    ${target_path} =    Join Path   ${DESTINATION_DIR_FULL_PATH}    this${/}path${/}does${/}not${/}exist${/}
    Create Directory    path=${target_path}     # Also possible intermediate directories are created

    # for the next test case
    Set Suite Variable  ${DEEP_TARGET_PATH}      ${target_path}

Use "Directory Should Be Empty"
    [Tags]      failure-expected
    Directory Should Be Empty   ${DEEP_TARGET_PATH}

    # intentional failure
    Run Keyword And Ignore Error    Directory Should Be Empty   ${DESTINATION_DIR_FULL_PATH}

Use "Directory Should Exist"
    [Tags]      failure-expected
    Directory Should Exist      ${DEEP_TARGET_PATH}

    # note that glob pattern contains many ? characters placed all over the full path
    ${glob_pattern} =  Catenate    ${DESTINATION_DIR_FULL_PATH}${/}?his${/}?ath${/}?oes${/}?ot${/}?xist${/}
    Directory Should Exist  ${glob_pattern}

    # intentional failure
    ${glob_pattern} =  Catenate    ${DESTINATION_DIR_FULL_PATH}${/}?his${/}?ath${/}?oes${/}?ot${/}?xist${/}non-existing
    Run Keyword And Ignore Error    Directory Should Exist      ${glob_pattern}

Use "Directory Should Not Be Empty"
    [Tags]      failure-expected
    # setup
    ${empty_dir_full_path} =  Join Path    ${ARTIFACTS_DIR_FULL_PATH}      ${EMPTY_DIR}
    Remove Directory    ${empty_dir_full_path}  recursive=${True}
    Create Directory    ${empty_dir_full_path}      # an empty directory is created

    # test: intentional failure
    Run Keyword And Ignore Error    Directory Should Not Be Empty   path=${empty_dir_full_path}

    # test
    Directory Should Not Be Empty   path=${ARTIFACTS_DIR_FULL_PATH}     # passes

Use "Directory Should Not Exist"
    [Tags]      failure-expected
    # test: intentional failure
    Run Keyword And Ignore Error    Directory Should Not Exist   path=${ARTIFACTS_DIR_FULL_PATH}

    ${path_to_non_existing_dir} =   Join Path   ${ARTIFACTS_DIR_FULL_PATH}      non-existing-dir
    Directory Should Not Exist      path=${path_to_non_existing_dir}

Use "Environment Variable Should Be Set"
    [Tags]      failure-expected
    Environment Variable Should Be Set   ENV_VAR2

    # test: intentional failure
    Run Keyword And Ignore Error    Environment Variable Should Be Set   NON_EXISTING_ENV_VAR

Use "Environment Variable Should Not Be Set"
    [Tags]      failure-expected
    Environment Variable Should Not Be Set   NON_EXISTING_ENV_VAR

    # test: intentional failure
    Run Keyword And Ignore Error    Environment Variable Should Not Be Set   ENV_VAR2

Use "File Should Be Empty"
    [Tags]      failure-expected
    # setup
    ${path_to_empty_file} =     Join Path       ${ARTIFACTS_DIR_FULL_PATH}      empty_file.txt
    Remove File     path=${path_to_empty_file}
    Create File     path=${path_to_empty_file}   content=   # an empty file

    # test
    File Should Be Empty    path=${path_to_empty_file}

    # test : intentional failure
    Run Keyword And Ignore Error    File Should Be Empty       path=${PATH_TO_CRAZY_MILO}

Use "File Should Not Exist"
    [Tags]      failure-expected
    # setup
    ${path_to_non_existing_file} =     Join Path       ${ARTIFACTS_DIR_FULL_PATH}      non_existing_file.txt

    # intentional failure
    Run Keyword And Ignore Error    File Should Not Exist       path=${PATH_TO_CRAZY_MILO}

    # test
    File Should Not Exist       path=${path_to_non_existing_file}

Use "Get Environment Variable" and %ENV_VAR Together
    ${value}=   Get Environment Variable    ENV_VAR
    Should Be Equal     ${value}        %{ENV_VAR}  # note %{ENV_VAR} syntax

Use "Get Environment Variables"
    ${env_vars}=   Get Environment Variables    # Returns currently available environment variables as a dictionary.
    FOR     ${var}  IN      @{env_vars}
        Log Many    ENV_VAR=${var}  ENV_VAR_VALUE=${env_vars}[${var}]     # ${var} is a key to dictionary ${env_vars}
    END

Use "Get File": Append The Contents Of Text File "example_1.txt" Into "example_2.txt"
    # setup
    ${path_to_file_one} =   Join Path   ${ARTIFACTS_DIR_FULL_PATH}      example_1.txt
    ${path_to_file_two} =   Join Path   ${ARTIFACTS_DIR_FULL_PATH}      example_2.txt

    # test
    ${file_one_content} =   Get File    path=${path_to_file_one}        encoding=UTF-8

    # append to example_2.txt
    Append To File      path=${path_to_file_two}    content=${file_one_content}     encoding=UTF-8

Use "Get Modified Time"
    [Documentation]     Get Modified Time 	path, format=timestamp
    # Otherwise, and by default, the time is returned as a timestamp string in the format 2006-02-24 15:08:31
    ${modified_time}=   Get Modified time   path=${PATH_TO_CRAZY_MILO}

    # If format contains any of the words year, month, day, hour, min or sec, only the selected parts are returned in a list.
    # The order of the returned parts is always the one in the previous sentence
    # and the order of the words in format is not significant.
    ${modified_time}=   Get Modified time   path=${PATH_TO_CRAZY_MILO}  format=sec,min,hour,year

    # If format contains the word epoch, the time is returned in seconds after the UNIX epoch.
    # The return value is always an integer.
    ${modified_time}=   Get Modified time   path=${PATH_TO_CRAZY_MILO}  format=epoch

Use "Grep File"
    [Documentation]     Grep File 	path, pattern, encoding=UTF-8, encoding_errors=strict
    # setup
    ${path_to_file} =   Join Path   ${ARTIFACTS_DIR_FULL_PATH}      example_2.txt

    ${first_grep} =     Grep File   path=${path_to_file}    pattern=h?r?
    ${second_grep} =    Grep File  path=${path_to_file}    pattern=[34]*
    ${third_grep} =     Grep File  path=${path_to_file}    pattern=l?n?s

Use "Join Paths"
    # PROJECT_FULL_PATH = /home/hakan/Python/Robot/robot-fw-operating-system-library-tests
    # test
    @{paths} =  Join Paths  ${PROJECT_FULL_PATH}     ../..             # [ /home/hakan/Python/ ]
    @{paths} =  join Paths  /base/path     dir1    dir2         # [ /base/path/dir1 | /base/path/dir2 ]
    @{paths} =  Join Paths   /base/path/ignored   /dir1   dir2  # [ /dir1 | /base/path/ignored/dir2 ]

Use "List Directories In Directory"
    [Documentation]
    ...     /home/hakan/Python/Robot/robot-fw-operating-system-library-tests/.idea
    ...     /home/hakan/Python/Robot/robot-fw-operating-system-library-tests/Artifacts
    ...     /home/hakan/Python/Robot/robot-fw-operating-system-library-tests/Copy
    ...     /home/hakan/Python/Robot/robot-fw-operating-system-library-tests/Copy2
    ...     /home/hakan/Python/Robot/robot-fw-operating-system-library-tests/Resources
    ...     /home/hakan/Python/Robot/robot-fw-operating-system-library-tests/Results
    ...     /home/hakan/Python/Robot/robot-fw-operating-system-library-tests/Tests
    @{directories} =    List Directories In Directory   ${PROJECT_FULL_PATH}   pattern=None     absolute=${True}
    FOR  ${d}    IN    @{directories}
        Log   ${d}
    END

    @{directories} =    List Directories In Directory   ${PROJECT_FULL_PATH}   pattern=R*s     absolute=${True}
    FOR  ${d}    IN    @{directories}
        Log   ${d}
    END

Use "List Directory" (To List Items In The Given Path)
    [Documentation]  Note that "List Directory" keyword does not operate recursively on the given subdirectories!
    ...              7 items:
    ...             /home/hakan/Python/Robot/robot-fw-operating-system-library-tests/.idea
    ...             /home/hakan/Python/Robot/robot-fw-operating-system-library-tests/Artifacts <- i.e. no recursive listing
    ...             /home/hakan/Python/Robot/robot-fw-operating-system-library-tests/Copy
    ...             /home/hakan/Python/Robot/robot-fw-operating-system-library-tests/Copy2
    ...             /home/hakan/Python/Robot/robot-fw-operating-system-library-tests/Resources
    ...             /home/hakan/Python/Robot/robot-fw-operating-system-library-tests/Results
    ...             /home/hakan/Python/Robot/robot-fw-operating-system-library-tests/Test
    @{items} =      List Directory   ${PROJECT_FULL_PATH}   pattern=None     absolute=${True}  # logs also the result

Use "List Files In Directory"
    ${path} =       Join Path      ${PROJECT_FULL_PATH}     Artifacts
    @{files} =      List Files In Directory     path=${path}    pattern=None   absolute=${True}   # logs also the result

Use "Log Environment Variables"
    &{env_vars} =    Log Environment Variables      level=INFO

Use "Log File" : To Log The Contents Of File
    ${path_to_file_one} =   Join Path   ${ARTIFACTS_DIR_FULL_PATH}      example_1.txt
    Log File    path=${path_to_file_one}    encoding=UTF-8   encoding_errors=strict

Use "Move Directory"
    # setup
    ${source_one} =      Join Path      ${PROJECT_FULL_PATH}        Copy
    ${source_two} =      Join Path      ${PROJECT_FULL_PATH}        Copy2
    ${dest} =        Join Path      ${PROJECT_FULL_PATH}        Artifacts${/}Trash
    Remove Directory    path=${dest}   recursive=${True}
    Create Directory    path=${dest}

    # test
    Move Directory   source=${source_one}       destination=${dest}
    Move Directory   source=${source_two}       destination=${dest}

Use "Move File"
    # setup
    ${path_to_crazy_milo_copy} =    Join Path   ${ARTIFACTS_DIR_FULL_PATH}      CrazyMilo(Copy).jpeg
    ${dest} =        Join Path      ${PROJECT_FULL_PATH}        Artifacts${/}Trash

    # test
    Move File    source=${path_to_crazy_milo_copy}       destination=${dest}

Use "Move Files"
    # setup
    ${path_to_files} =      Join Path      ${PROJECT_FULL_PATH}        Artifacts${/}Trash${/}Copy${/}Here
    @{files} =  List Files In Directory     path=${path_to_files}      absolute=${True}
    ${target_path} =        Join Path      ${PROJECT_FULL_PATH}        Artifacts${/}Trash

    # test
    Move Files      @{files}      ${target_path}

Use "Normalize Path"
    ${path1} = 	Normalize Path 	abc/
    ${path2} = 	Normalize Path 	abc/../def
    ${path3} = 	Normalize Path 	abc/./def//ghi
    ${path4} = 	Normalize Path 	~/robot/stuf

Use "Remove Environment Variable"
    Remove Environment Variable     ENV_VAR     ENV_VAR2

Use "Remove File"
    ${full_path_to_file} =   Join Path      ${PROJECT_FULL_PATH}        Artifacts${/}Trash${/}CrazyMilo(Copy).jpeg
    Remove File   ${full_path_to_file}

Use "Remove Files"
    # setup
    ${full_path_to_files} =   Join Path      ${PROJECT_FULL_PATH}        Artifacts${/}Trash${/}
    @{files} =  List Files In Directory     path=${full_path_to_files}      absolute=${True}

    # test
    Remove Files   @{files}

Use "Run" : To Execute A Bash Script To Remove A Given Folder
    # setup
    ${full_path_to_folder} =       Join Path      ${PROJECT_FULL_PATH}        Artifacts${/}Trash${/}Copy2
    ${full_path_to_batch_file} =   Join Path      ${PROJECT_FULL_PATH}        Artifacts${/}delete_given_folder.sh
    ${command} =    Catenate       ${full_path_to_batch_file}   ${full_path_to_folder}

    # test
    Directory Should Exist          ${full_path_to_folder}
    Run     ${command}
    Directory Should Not Exist      ${full_path_to_folder}

Use "Run and Return Rc"
    # note that in the previous test case, Artifacts${/}Trash${/}Copy2 folder already removed
    # setup
    ${full_path_to_folder} =       Join Path      ${PROJECT_FULL_PATH}        Artifacts${/}Trash${/}Copy2
    ${full_path_to_batch_file} =   Join Path      ${PROJECT_FULL_PATH}        Artifacts${/}delete_given_folder.sh
    ${command} =    Catenate       ${full_path_to_batch_file}   ${full_path_to_folder}

    # test
    Directory Should Not Exist      ${full_path_to_folder}
    ${rc} =     Run And Return Rc     ${command}        # rc is 0

    # setup
    ${wrong_full_path_to_folder} =  Join Path      ${PROJECT_FULL_PATH}        Artifacts${/}Trash${/}DoesNotExist
    ${command} =    Catenate       rmdir   ${wrong_full_path_to_folder}

    # test
    ${rc} =     Run And Return Rc   ${command}        # rc is 1

Use "Run And Return Rc And Output"
    # setup
    ${wrong_full_path_to_folder} =  Join Path      ${PROJECT_FULL_PATH}        Artifacts${/}Trash${/}DoesNotExist
    ${command} =    Catenate       rmdir   ${wrong_full_path_to_folder}

    # test
    # rc is 1
    # ${output} = rmdir: failed to remove '/home/hakan/Python/Robot/robot-fw-operating-system-library-tests/Artifacts/Trash/DoesNotExist': No such file or directory
    ${rc}  ${output} =     run and return rc and output  ${command}

Use "Set Environment Variable"
    # test
    ${expected} =   set variable  Value

    # verification
    Set Environment Variable    ENV_VAR     ${expected}
    ${observed} =   Get Environment Variable    ENV_VAR
    should be equal     ${expected}     ${observed}

Use "Set Modified Time"
    # setup
    ${full_path_to_file_1} =  Do Create File  target_path=${PATH_TO_TRASH}    file_name=file_1.txt    file_content=
    ${full_path_to_file_2} =  Do Create File  target_path=${PATH_TO_TRASH}    file_name=file_2.txt    file_content=
    ${full_path_to_file_3} =  Do Create File  target_path=${PATH_TO_TRASH}    file_name=file_3.txt    file_content=
    ${full_path_to_file_4} =  Do Create File  target_path=${PATH_TO_TRASH}    file_name=file_4.txt    file_content=
    ${full_path_to_file_5} =  Do Create File  target_path=${PATH_TO_TRASH}    file_name=file_5.txt    file_content=
    ${full_path_to_file_6} =  Do Create File  target_path=${PATH_TO_TRASH}    file_name=file_5.txt    file_content=

    # test
    # If mtime is a number, or a string that can be converted to a number,
    # it is interpreted as seconds since the UNIX epoch (1970-01-01 00:00:00 UTC).
    Set Modified Time   path=${full_path_to_file_1}     mtime=0
    # TODO: This one fails on windows, i donno why?
    Set Modified Time   path=${full_path_to_file_2}     mtime=1970-01-01 00:00:00  # ValueError: Invalid time format

    # test
    # If mtime is a timestamp, that time will be used. Valid timestamp formats are:
    # YYYY-MM-DD hh:mm:ss and YYYYMMDD hhmmss
    Set Modified Time  path=${full_path_to_file_3}      mtime=2023-12-04 12:12:12

    # test: If mtime is equal to NOW, the current local time is used
    Set Modified Time  path=${full_path_to_file_4}      mtime=NOW + 1 day

    # test: If mtime is equal to UTC, the current time in UTC is used.
    Set Modified Time  path=${full_path_to_file_5}      mtime=UTC + 1 day

    # test: If mtime is in the format like NOW - 1 day or UTC + 1 hour 30 min,
    # the current local/UTC time plus/minus the time specified with the time string is used.
    Set Modified Time  path=${full_path_to_file_6}      mtime=UTC + 1h 2min 3s

Use "Should Exist"
    # The path can be given as an exact path
    should exist  path=${PATH_TO_TRASH}
    run keyword and ignore error  should exist  path=/non/existing/path
    should exist  path=${PATH_TO_CRAZY_MILO}
    ${full_path_to_non_existing_file} =   join path  ${PATH_TO_TRASH}   none_existing_file.txt
    run keyword and ignore error  should exist  ${full_path_to_non_existing_file}

    # The path can be given as a glob pattern.
    ${globby_path} =  join path  ${PATH_TO_TRASH}   file_?.txt
    should exist  ${globby_path}
    ${globby_path} =    join path  ${PROJECT_FULL_PATH}     A*s
    should exist  ${globby_path}
    ${globby_path} =    join path  ${PROJECT_FULL_PATH}     non_ex?st?ng_path
    run keyword and ignore error  should exist  ${globby_path}

Use "Should Not Exist"
    # The path can be given as an exact path
    run keyword and ignore error  should not exist  path=${PATH_TO_TRASH}
    should not exist  path=/non/existing/path
    run keyword and ignore error  should not exist  path=${PATH_TO_CRAZY_MILO}
    ${full_path_to_non_existing_file} =   join path  ${PATH_TO_TRASH}   none_existing_file.txt
    should not exist  ${full_path_to_non_existing_file}

    # The path can be given as a glob pattern.
    ${globby_path} =  join path  ${PATH_TO_TRASH}   bad_globbing_?.txt
    should not exist  ${globby_path}
    ${globby_path} =    join path  ${PROJECT_FULL_PATH}     A*s
    run keyword and ignore error  should not exist  ${globby_path}
    ${globby_path} =    join path  ${PROJECT_FULL_PATH}     non_ex?st?ng_path
    should not exist  ${globby_path}

Use "Split Extention"
    ${path}     ${ext} = 	Split Extension 	file.extension
    ${p2} 	${e2} = 	Split Extension 	path/file.ext
    ${p3} 	${e3} = 	Split Extension 	path/file
    ${p4} 	${e4} = 	Split Extension 	p1/../p2/file.ext
    ${p5} 	${e5} = 	Split Extension 	path/.file.ext
    ${p6} 	${e6} = 	Split Extension 	path/.file

    # ${path} = 'file' & ${ext} = 'extension'
    # ${p2} = 'path/file' & ${e2} = 'ext'
    # ${p3} = 'path/file' & ${e3} = ''
    # ${p4} = 'p2/file' & ${e4} = 'ext'
    # ${p5} = 'path/.file' & ${e5} = 'ext'
    # ${p6} = 'path/.file' & ${e6} = ''

Use "Split Path"
    ${path1} 	${dir} = 	Split Path 	abc/def
    ${path2} 	${file} = 	Split Path 	abc/def/ghi.txt
    ${path3} 	${d2} = 	Split Path 	abc/../def/ghi/

    # ${path1} = 'abc' & ${dir} = 'def'
    # ${path2} = 'abc/def' & ${file} = 'ghi.txt'
    # ${path3} = 'def' & ${d2} = 'ghi'

Use "Wait Until Created"
    Wait Until Created      path=${WAIT_FOR_ME}     timeout=15 seconds

Use "Wait Until Removed"
    Wait Until Removed      path=${WAIT_FOR_ME}     timeout=15 seconds