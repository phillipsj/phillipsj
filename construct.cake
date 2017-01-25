#tool nuget:?package=Wyam&prerelease
#addin nuget:?package=Cake.Wyam&prerelease
#addin nuget:?package=Cake.Npm

//////////////////////////////////////////////////////////////////////
// ARGUMENTS
//////////////////////////////////////////////////////////////////////

var target = Argument("target", "Default");

//////////////////////////////////////////////////////////////////////
// TASKS
//////////////////////////////////////////////////////////////////////

Task("Install-Netlify-Cli")
    .Does(()=> {
        Npm.Install(settings=>settings.Package("netlify-cli"));
    });


Task("Build")
    .Does(() => {
        Wyam(new WyamSettings {
            Recipe = "Blog",
            Theme = "CleanBlog",
            UpdatePackages = true
        });        
    });
    
Task("Preview")
    .Does(() => {
        Wyam(new WyamSettings {
            Recipe = "Blog",
            Theme = "CleanBlog",
            UpdatePackages = true,
            Preview = true,
            Watch = true
        });        
    });

Task("Debug")
    .Does(() => {
        StartProcess("../Wyam/src/clients/Wyam/bin/Debug/wyam.exe",
            "-a \"../Wyam/src/**/bin/Debug/*.dll\" -r \"blog -i\" -t \"../Wyam/themes/Blog/CleanBlog\" -p --attach");
    });

Task("Deploy")
    .IsDependentOn("Build")
    .Does(() => {
        var token = EnvironmentVariable("NETLIFY_PHILLIPSJ");
        if(string.IsNullOrEmpty(token)) {
            throw new Exception("Could not get NETLIFY_PHILLIPSJ environment variable");
        }
        
        // Upload via curl and zip instead
        Zip("./output", "output.zip", "./output/**/*");
        StartProcess("curl", "--header \"Content-Type: application/zip\" --header \"Authorization: Bearer " + token + "\" --data-binary \"@output.zip\" --url https://api.netlify.com/api/v1/sites/phillipsj.netlify.com/deploys");
    });

Task("Netlify-Deploy")
    .IsDependentOn("Build")
    .Does(() => {
        var token = EnvironmentVariable("NETLIFY_PHILLIPSJ");
        if(string.IsNullOrEmpty(token)) {
            throw new Exception("Could not get NETLIFY_PHILLIPSJ environment variable");
        }
        
        // Upload via curl and zip instead
        Npm.RunScript($"netlify deploy output -s phillipsj.netlify.com -t {token}");
    });
    
//////////////////////////////////////////////////////////////////////
// TASK TARGETS
//////////////////////////////////////////////////////////////////////

Task("Default")
    .IsDependentOn("Preview");    
    
Task("AppVeyor")
    .IsDependentOn("Deploy");

//////////////////////////////////////////////////////////////////////
// EXECUTION
//////////////////////////////////////////////////////////////////////

RunTarget(target);
