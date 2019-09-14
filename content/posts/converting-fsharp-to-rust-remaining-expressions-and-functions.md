---
Title: "Converting F# to Rust: Remaining expressions and functions"
date: 2019-08-31T13:14:34
Tags: 
- Rust
- Rustacean
- Open Source
- FSharp
- .NET
---
# Converting F# to Rust: Remaining expressions and functions

I am back with the final post on converting an existing F# app to Rust. The discriminated union is a crucial piece, and the last remaining part that will be difficult is the function that converts my data structure into a set of files and paths to create. Since the data structure lends itself to recursion, that is the essence of this last function. Before we dive into that function, let's show the other pieces. I will use the heading to describe what is happening, and both code snippets are below. If you see anything, you would like to ask about don't hesitate reach out to me.

## Generic functions used in the snippets below

F# 

```FSharp
let toTuple a b = (a,b)
```

Rust

```Rust
fn convert_strings_to_files(file_names: &[&str]) -> Vec<Folder> {
    file_names
        .into_iter()
        .map(|name| Folder::File(name.to_string()))
        .collect()
}
```

## Creating the envs folder

F#

```FSharp
let envsFolder = 
    ["dev.tfvars"; "qa.tfvars"; "prod.tfvars"]
    |> List.map File
    |> toTuple "envs"
    |> Folder
```

Rust

```Rust
fn generate_envs_folder() -> Folder {
    let env_files = convert_strings_to_files(&["dev.tfvars", "qa.tfvars", "prod.tfvars"]);
    Folder::Folder(String::from("envs"), env_files)
}
```

## Creating the service folder

F#

```FSharp
let service serviceName =
    [File "main.tf"; File "variables.tf"; File "output.tfvars"; envsFolder]
    |> toTuple serviceName
    |> Folder
```

Rust

```Rust
fn generate_service_folder(name: &str) -> Folder {
    let envs_folder = generate_envs_folder();
    let mut files = convert_strings_to_files(&["main.tf", "variables.tf", "output.tf"]);
    files.push(envs_folder);
    Folder::Folder(name.to_string(), files)
}
```

## Creating the infrastructure folder

F#

```FSharp
let infrastructureFolder serviceFolder = Folder("infrastructure", [serviceFolder])
```

Rust

```Rust
fn generate_infrastructure_folder(app_name: &str) -> Folder {
    let service_folder = generate_service_folder(app_name);
    Folder::Folder("infrastructure".to_string(), vec![service_folder])
}
```

## The Piece De Resistance

This function is the most exciting piece of the whole app outside of the data structure. The function converts the data structure that was built and generate the full paths from the structure. Since the data structure is recursive, this is a recursive function.

Here it is in F#:

```FSharp
let rec folderToString folder =
    match folder with
    | File fileName -> [fileName]
    | Folder (name, []) -> [name + "/"]
    | Folder (name, otherFolders) ->
        otherFolders |> List.map folderToString |> List.collect (fun s -> s |> List.map (fun x -> name + "/" + x))
```

The function in Rust ended up with a list inside of a list. After about an hour fighting with the compiler, I realized that I needed to use a flat map instead.

Here is the working Rust version:

```Rust
fn generate_paths(filesystem: Folder) -> Vec<PathBuf> {
    let file_paths = match filesystem {
        Folder::File(x) => vec![PathBuf::from(x)],
        Folder::Folder(folder, folders) => folders
            .into_iter()
            .flat_map(|path| generate_paths(path))
            .collect::<Vec<PathBuf>>()
            .into_iter()
            .map(|path| PathBuf::from(&folder).join(path))
            .collect(),
    };
    file_paths
}
```

## The IO bits

F#

```FSharp
let createFile (fileName: string) = 
    Directory.CreateDirectory(Path.GetDirectoryName(fileName)) |> ignore
    File.Create(fileName).Close()
```

Rust

```Rust
fn create_path(path: PathBuf) -> std::io::Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?
    }
    File::create(path)?;
    Ok(())
}
```

## The Main function, the entrypoint

Nothing extraordinary here.

F#

```FSharp
[<EntryPoint>]
let main argv =
    match Array.tryHead argv with
    | Some serviceName -> serviceName |> service |> infrastructureFolder |> folderToString |> List.iter createFile
    | None -> printfn "No service name provided!"
    0 // return an integer exit code
```

Rust

```Rust
fn main() -> std::io::Result<()> {
    let filesystem = generate_infrastructure_folder("myapp");
    let paths = generate_paths(filesystem);
    for path in paths {
        create_path(path)?;
    }

    Ok(())
}
```

## All of it together

Here is the complete application in both languages.

F#

```FSharp
open System.IO

type Folder = File of string | Folder of string * Folder list

let toTuple a b = (a,b)

let envsFolder = 
    ["dev.tfvars"; "qa.tfvars"; "prod.tfvars"]
    |> List.map File
    |> toTuple "envs"
    |> Folder

let service serviceName =
    [File "main.tf"; File "variables.tf"; File "output.tfvars"; envsFolder]
    |> toTuple serviceName
    |> Folder

let infrastructureFolder serviceFolder = Folder("infrastructure", [serviceFolder])

// type FolderPrinter = FolderPrinter of (Folder -> string list)


let rec folderToString folder =
    match folder with
    | File fileName -> [fileName]
    | Folder (name, []) -> [name + "/"]
    | Folder (name, otherFolders) ->
        otherFolders |> List.map folderToString |> List.collect (fun s -> s |> List.map (fun x -> name + "/" + x))

let createFile (fileName: string) =
    Directory.CreateDirectory(Path.GetDirectoryName(fileName)) |> ignore
    File.Create(fileName).Close()


[<EntryPoint>]
let main argv =
    match Array.tryHead argv with
    | Some serviceName -> serviceName |> service |> infrastructureFolder |> folderToString |> List.iter createFile
    | None -> printfn "No service name provided!"
    0 // return an integer exit code
```

Rust

```Rust
use std::fs;
use std::fs::File;
use std::path::PathBuf;

enum Folder {
    File(String),
    Folder(String, Vec<Folder>),
}

fn convert_strings_to_files(file_names: &[&str]) -> Vec<Folder> {
    file_names
        .into_iter()
        .map(|name| Folder::File(name.to_string()))
        .collect()
}

fn generate_envs_folder() -> Folder {
    let env_files = convert_strings_to_files(&["dev.tfvars", "qa.tfvars", "prod.tfvars"]);
    Folder::Folder(String::from("envs"), env_files)
}

fn generate_service_folder(name: &str) -> Folder {
    let envs_folder = generate_envs_folder();
    let mut files = convert_strings_to_files(&["main.tf", "variables.tf", "output.tf"]);
    files.push(envs_folder);
    Folder::Folder(name.to_string(), files)
}

fn generate_infrastructure_folder(app_name: &str) -> Folder {
    let service_folder = generate_service_folder(app_name);
    Folder::Folder("infrastructure".to_string(), vec![service_folder])
}

fn generate_paths(filesystem: Folder) -> Vec<PathBuf> {
    let file_paths = match filesystem {
        Folder::File(x) => vec![PathBuf::from(x)],
        Folder::Folder(folder, folders) => folders
            .into_iter()
            .flat_map(|path| generate_paths(path))
            .collect::<Vec<PathBuf>>()
            .into_iter()
            .map(|path| PathBuf::from(&folder).join(path))
            .collect(),
    };
    file_paths
}

fn create_path(path: PathBuf) -> std::io::Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?
    }
    File::create(path)?;
    Ok(())
}

fn main() -> std::io::Result<()> {
    let filesystem = generate_infrastructure_folder("myapp");
    let paths = generate_paths(filesystem);
    for path in paths {
        create_path(path)?;
    }

    Ok(())
}
```

## Conclusion

I have more things to add to this app, and I will blog about those features as I add them. I will also announce the name of this app and do a release shortly. I hope you are finding this helpful and exciting. I am enjoying Rust.

Thanks for reading,

Jamie
