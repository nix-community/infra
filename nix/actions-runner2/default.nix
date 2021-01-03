{ stdenv
, fetchFromGitHub
, fetchurl
, makeWrapper
, dotnetCorePackages
, dotnetPackages
, mono
# , mono6
}:

let

  deps = import ./deps.nix { inherit fetchurl; };

in

stdenv.mkDerivation rec {
  pname = "ActionsRunner";
  version = "2.275.1";

  src = fetchFromGitHub {
    owner = "actions";
    repo = "runner";
    rev = "v${version}";
    sha256 = "0xpi5yhm1yzxf7a7dzigiaf9s4lmvvav9qjvx68a7z0cxf3chwb2";
  };

  buildInputs = [
    dotnetCorePackages.sdk_5_0
    dotnetPackages.Nuget
    makeWrapper
    # mono6
    mono
  ];

  buildPhase = ''
    mkdir home
    export HOME=$PWD/home
    export DOTNET_CLI_TELEMETRY_OPTOUT=1
    export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
    export FrameworkPathOverride=${mono}/lib/mono/4.7.1-api

    # disable default-source so nuget does not try to download from online-repo
    nuget sources Disable -Name "nuget.org"
    # add all dependencies to a source called 'nixos'
    for package in ${toString deps}; do
      nuget add $package -Source nixos
    done

    dotnet restore --source nixos src/ActionsRunner.sln
    dotnet build --no-restore -c Release src/ActionsRunner.sln
  '';

  installPhase = ''
    mkdir $out
    cp -r bin $out/bin
    # mkdir -p $out/{bin,lib/runner}
    # cp -r bin/Release/* $out/lib/runner
    # makeWrapper "${mono}/bin/mono" $out/bin/runner \
    #   --add-flags "$out/lib/eventstore/EventStore.ClusterNode/net471/EventStore.ClusterNode.exe"
  '';

  doCheck = true;

  checkPhase = ''
    # dotnet test src/EventStore.Projections.Core.Tests/EventStore.Projections.Core.Tests.csproj -- RunConfiguration.TargetPlatform=x64
  '';

  meta = {
    homepage = "https://github.com/features/actions";
    description = "The Runner for GitHub Actions";
    license = stdenv.lib.licenses.mit;
    maintainers = with stdenv.lib.maintainers; [ zimbatm ];
    platforms = [ "x86_64-linux" ];
  };

}
