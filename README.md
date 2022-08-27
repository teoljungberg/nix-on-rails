# Nix on Rails

An example of what is required to run your run-of-the-mill Rails application.

## Setup

```
% bin/nix-on-rails /path/to/project
```

## Testing

```
% sh $(nix-build --no-out-link --attr test)/test.sh
```
