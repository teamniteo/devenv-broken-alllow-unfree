{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [ pkgs.git ];

  apple.sdk = null; # use env apple sdk, fixes broken mongodb compile step

  services.mongodb.enable = true;
  services.mongodb.additionalArgs = [
    "--noauth"
    "--quiet"
  ];

  # https://devenv.sh/languages/
  # languages.rust.enable = true;

  # https://devenv.sh/processes/
  # processes.cargo-watch.exec = "cargo-watch";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';

  enterShell = ''
    hello
    git --version
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;

  processes = {
    mongodb.process-compose = {
      readiness_probe = {
        exec.command = "${pkgs.curl}/bin/curl -f -k http://127.0.0.1:27017/";
        initial_delay_seconds = 5;
        period_seconds = 5;
        timeout_seconds = 2;
        success_threshold = 1;
        failure_threshold = 5;
      };
      availability.restart = "on_failure";
    };
    mongodb-configure.process-compose = {
      depends_on.mongodb.condition = "process_healthy";
    };
  };

  pre-commit.hooks = {
    alejandra.enable = true;
  };

}
