{ fetchurl
, runCommandLocal
, makeWrapper
, jre_headless
}:
let
  pname = "lemminx";
  version = "0.24.0";
  jar = fetchurl {
    url = "https://repo.eclipse.org/content/repositories/lemminx-releases/org/eclipse/lemminx/org.eclipse.lemminx/${version}/org.eclipse.lemminx-${version}-uber.jar";
    sha256 = "sha256-s2g+qB4aXv+J903qGgOdxJstFkX6JEf+5GdbUoZ/QpA=";
  };
in
runCommandLocal "${pname}-${version}"
{
  nativeBuildInputs = [ makeWrapper ];
} ''
  makeWrapper ${jre_headless}/bin/java $out/bin/${pname} \
    --add-flags "-jar ${jar}"
''
