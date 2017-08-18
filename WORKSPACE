workspace(name = "debian_docker")

# Docker rules.
git_repository(
    name = "io_bazel_rules_docker",
    commit = "9a1a7cba78d790cd94d3a04f5291fbcc53181bff",
    remote = "https://github.com/bazelbuild/rules_docker.git",
)

load(
    "@io_bazel_rules_docker//docker:docker.bzl",
    "docker_repositories", "docker_pull"
)

docker_repositories()

docker_pull(
  name = "debian_base",
  registry = "gcr.io",
  repository = "google-appengine/debian8",
  digest = "sha256:987494b558cc0c9c341b5808b6e259ee449cf70c6f7c7adce4fd8f15eef1dea2",
)


git_repository(
    name = "distroless",
    commit = "e6c9254b04bd2cb4c171ece3c91d8b997a20c30c",
    remote = "https://github.com/GoogleCloudPlatform/distroless.git"
)

load(
    "@distroless//package_manager:package_manager.bzl",
    "package_manager_repositories",
    "dpkg_src",
    "dpkg_list",
)

package_manager_repositories()

# The Debian snapshot datetime to use. See http://snapshot.debian.org/ for more information.
SNAPSHOT="20170816T214423Z"

dpkg_src(
    name = "debian_jessie",
    arch = "amd64",
    distro = "jessie",
    sha256 = "142cceae78a1343e66a0d27f1b142c406243d7940f626972c2c39ef71499ce61",
    snapshot = SNAPSHOT,
    url = "http://snapshot.debian.org/archive",
)

# These are needed to install debootstrap.
dpkg_list(
    name = "package_bundle",
    packages = [
        "debootstrap",
        "libffi6",
        "libgmp10",
        "libgnutls-deb0-28",
        "libhogweed2",
        "libicu52",
        "libidn11",
        "libnettle4",
        "libp11-kit0",
        "libpsl0",
        "libtasn1-6",
        "wget",
],

    sources = [
        "@debian_jessie//file:Packages.json",
    ],
)

git_repository(
    name = "runtimes_common",
    commit = "3d73b4fecbd18de77588ab5eef712d50f34f601e",
    remote = "https://github.com/GoogleCloudPlatform/runtimes-common.git",
)