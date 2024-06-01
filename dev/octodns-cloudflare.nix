{ python3, fetchFromGitHub, octodns }:

with python3.pkgs;

buildPythonPackage rec {
  pname = "octodns-cloudflare";
  version = "0.0.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "octodns";
    repo = "octodns-cloudflare";
    rev = "v${version}";
    hash = "sha256-qjacnAXXX/dVLaXaGSgIG+JZjInqhJHai0Ft5LkQs1k=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [ octodns requests ];

  env.OCTODNS_RELEASE = 1;

  pythonImportsCheck = [ "octodns_cloudflare" ];

  nativeCheckInputs = [ pytestCheckHook requests-mock ];
}
