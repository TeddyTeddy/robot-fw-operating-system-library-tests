def get_variables():
    variables = {
        'COMMANDS': {
            'Windows': {
                'get_project_full_path': 'cd',
                },
            'Linux': {
                'get_project_full_path': 'pwd',
            },
        },
    }
    return variables
