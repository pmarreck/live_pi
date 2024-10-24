{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # 22.11";
    systems.url = "github:nix-systems/default";
  };

  outputs = { self, nixpkgs, systems, ... } @ inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      #### SHELL DEFINITION(S) ####
      devShells = forEachSystem
        (system:
          # "legacyPackages" is how nix flakes integrate with pre-flakes Nix
          with nixpkgs.legacyPackages.${system};
          let
            name = "LivePi";
            inherit (lib) optional optionals;
            inherit (stdenv) isLinux isDarwin;
            erlang = erlang_27;
            elixir = beam.packages.erlang_27.elixir_1_17;
            # postgresql = postgresql_16;
          in
          {
            default = pkgs.mkShell {
              enableParallelBuilding = true;
              # nativeBuildInputs are packages that are only needed at build time, and are not required at runtime
              nativeBuildInputs = [
                pkg-config # for compiling native extensions
                bashInteractive # for interactive bash shell
                graphviz # for generating diagrams
                direnv # for loading custom environments per directory
                bash-preexec # for bash shell hooks
                starship # for a nice shell prompt
                # For flyctl, please manage it separately using its own installer
                # as it's deprecated too frequently to be managed by Nix:
                # curl -L "https://fly.io/install.sh" | sh
                # Then manually add these env vars to your $HOME/.bash_profile (or similar)
                # export FLYCTL_INSTALL="$HOME/.fly"
                # export PATH="$FLYCTL_INSTALL/bin:$PATH"
              ];
              # buildInputs are packages that your project depends on at runtime
              # Since we used "with" above, we can refer to the packages directly
              # instead of namespaced as, for example, "pkgs.erlang" or "pkgs.elixir"
              buildInputs = [
                git # for version control
                vips # image processing lib; may need for profile photo uploads
                erlang # erlang runtime; specific version defined above
                elixir # elixir runtime; specific version defined above
                hex # elixir package manager
                rebar # erlang package manager
                nodejs # spaghetticode manager
                nodePackages.mocha # spaghetticode test runner
                yarn # another spaghetticode package manager
                # postgresql # database; specific version defined above
                has # for verifying the availability and version of executables. also, direnv uses it
                gawkInteractive # big fan of awk
                # busybox # for a whole bunch of standard unix utilities, not supported on mac
                unixtools.xxd # for hexdumping
                act # for running github actions locally
                cacert # for ssl certs
                elixir-ls # for elixir language server
              ] ++ optional isLinux inotify-tools
                ++ optional isLinux libnotify
                ++ optional isDarwin terminal-notifier
                ++ optionals isDarwin (with darwin.apple_sdk.frameworks; [
                    CoreFoundation
                    CoreServices
                ]);
              inputsFrom = [ erlang elixir vips ];
              shellHook = ''
                # note that we cannot define bash functions or aliases here; they will not be available in the dev shell
                # due to how direnv works: https://github.com/direnv/direnv/issues/73
                # Instead we add them as scripts to ./bin/ and put bin on PATH in .envrc
                # (which gets picked up by direnv).
                # export NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1;
                if ! [[ -v STARSHIP_CONFIG ]]; then
                  export STARSHIP_CONFIG=$PWD/.starship.toml
                fi
                export __bp_enable_subshells="true"
              '';
            };
          }
        );
      #### BUILD DEFINITION(S) ####
      packages = forEachSystem
        (system:
          with nixpkgs.legacyPackages.${system};
          let
            name = "LivePi";
            erlang = erlang_27;
            elixir = beam.packages.erlang_27.elixir_1_17;
            buildInputs = [
              vips
              elixir
              erlang
              hex
              rebar
              nodejs
              yarn
            ];
          in
          {
            default = stdenv.mkDerivation {
              inherit name;
              src = ./.;
              inherit buildInputs;
              buildPhase = ''
                export LANG=en_US.UTF-8
                echo "Fetching dependencies for ${name}..."
                ${elixir}/bin/mix deps.get
                echo "Compiling assets for ${name}..."
                ${nodejs}/bin/npm install --prefix assets
                ${nodejs}/bin/npm run deploy --prefix assets
                ${elixir}/bin/mix phx.digest
                echo "Building ${name} release..."
                MIX_ENV=prod ${elixir}/bin/mix release
              '';
              installPhase = ''
                mkdir -p $out
                cp -R _build/prod/rel/${name}/* $out/
              '';
            };
          });
    };
}
