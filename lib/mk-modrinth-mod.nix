{ fetchurl }:

/**
  Build a single mod/plugin jar derivation from a resolved lock entry.

  # Example

  ```nix
  mkModrinthMod {
    pname = "lithium";
    version = "0.20.0+mc1.21.10";
    url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/oGKQMdyZ/lithium-fabric-0.20.0%2Bmc1.21.10.jar";
    sha512 = "...";
  }
  ```
*/
{
  pname,
  version,
  url,
  sha512,
}:
fetchurl {
  name = "${pname}-${version}.jar";
  inherit url sha512;
}
