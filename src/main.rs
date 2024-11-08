use std::{env, error::Error, path::Path};

fn main() -> Result<(), Box<dyn Error>> {
    println!("Hello, world!");
    let path = env::var("NIX_PATH")?;
    let nixpkgs = path
        .split(":")
        .find(|s| s.starts_with("nixpkgs="))
        .ok_or("nixpkgs not found")?;

    println!("nixpkgs: {}", nixpkgs);

    let path_slice = nixpkgs
        .strip_prefix("nixpkgs=")
        .ok_or("nixpkgs prefix not found")?;

    finder(Path::new(path_slice))
}

fn finder(path: &Path) -> Result<(), Box<dyn Error>> {
    let is_dir = path.is_dir();

    let mut files = vec![];
    println!("{:?} is_dir: {}", path, is_dir);

    let mut dirs = path
        .read_dir()?
        .map(|e| e.map(|e| e.path()))
        .collect::<Result<Vec<_>, _>>()?;

    while let Some(path) = dirs.pop() {
        let is_dir = path.is_dir();
        let is_sym = path.is_symlink();
        let is_file = path.is_file();
        println!("{:?} is_dir: {}, is_symlink: {}", path, is_dir, is_sym);

        if !is_sym {
            if is_dir {
                dirs.push(path.clone());
            }

            if is_file {
                let ext = path.extension().and_then(|s| s.to_str());
                if ext == Some("nix") {
                    files.push(path);
                }
            }
        }
    }

    println!("files: {:?}", files);

    Ok(())
}
