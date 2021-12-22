# Nix on Rails

An example of what is required to run your run-of-the-mill Rails application.

## Setup

1. Copy `shell.nix` into your project.
1. Replace `nix-on-rails` with the name of your project.
1. Copy `bin/mainframe` into your project.
1. Setup direnv: `direnv allow`.
1. Copy `gitignore-sample` into `.git/info/exclude`.

## Testing

```
% nix-build --no-out-link
```
