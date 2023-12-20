{ lib, buildNpmPackage, fetchFromGitHub, python3 }:

buildNpmPackage rec {
  pname = "renovate";
  version = "37.89.5";

  src = fetchFromGitHub {
    owner = "renovatebot";
    repo = pname;
    rev = version;
    hash = "sha256-Obplx/H8IvoMMTVgVWVGOLfFbMmrNnP4j94T+Qicusw=";
  };

  nativeBuildInputs = [
    python3
  ];

  npmDepsHash = "sha256-N3cfQpQNcz4s1XH5rVX1QjztWo3ReVjKE9dw2KsO9ws=";

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Automated dependency updates. Multi-platform and multi-language";
    homepage = "https://github.com/renovatebot/renovate";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ xgwq janik ];
  };
}
