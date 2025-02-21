@{

    # Script module or binary module file associated with this manifest.
    ModuleToProcess = 'DeepShell.psm1'
    
    # Version number of this module.
    ModuleVersion = '0.0.1'
    
    # ID used to uniquely identify this module
    GUID = 'ce681b13-2fa8-48ed-b765-b1ec9b4236b9'
    
    # Author of this module
    Author = 'yuhuison'

    # Description of the functionality provided by this module
    Description = 'Pester provides a framework for running BDD style Tests to execute and validate PowerShell commands inside of PowerShell and offers a powerful set of Mocking Functions that allow tests to mimic and mock the functionality of any command inside of a piece of powershell code being tested. Pester tests can execute any command or script that is accesible to a pester test file. This can include functions, Cmdlets, Modules and scripts. Pester can be run in ad hoc style in a console or it can be integrated into the Build scripts of a Continuous Integration system.'
    
    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '2.0'
    
    # Functions to export from this module
    FunctionsToExport = @( 
        'Ds'
    )
    

    }
    