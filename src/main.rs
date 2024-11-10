use rnix::{
    ast::{AstNode, AstToken},
    tokenize, Root, SyntaxKind,
};
use std::{any::Any, collections::HashSet, error::Error, fs, hash::Hash, path::Path};

fn main() -> Result<(), Box<dyn Error>> {
    println!("Hello, world!");

    let path = Path::new("example/configuration.nix");
    assert!(path.exists());

    let content = fs::read_to_string(path)?;

    // let mut identifiers = HashSet::new();

    // let tokens = tokenize(&content);
    // for tk in tokens.iter() {
    //     println!("token={:?}", tk);
    //     if tk.0 == SyntaxKind::TOKEN_IDENT {
    //         identifiers.insert(tk.1);
    //     }
    // }

    // println!("identifiers={:?}", identifiers);

    let parse_root = Root::parse(&content);
    let root = parse_root.ok()?;

    println!("root={:?}", root);

    // let token_strings = tokens
    //     .iter()
    //     .map(|(tk, content)| format!("tk={:?}, content={}", tk, content))
    //     .collect::<Vec<_>>();
    // fs::write("output.txt", token_strings.join("\n"))?;

    Ok(())
}
