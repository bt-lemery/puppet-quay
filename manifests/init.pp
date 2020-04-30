# Quay Puppet module main class
#
# @summary This class installs and configures Quay (https://www.projectquay.io)
#
# @example
#   include quay
#
# @param version
#   Specifies the Quay version to install. See available releases at {https://github.com/quay/quay/releases}
#
# @param checksum
#   Specifies the MD5 checksum for downloaded Quay installation tar file.
#
# @param http_proxy
#   Defaults to None
#
# @param https_proxy
#   Defaults to None
#
# @param no_proxy
#  Defaults to None
#
# @param download_source
#   Specifies download location for the Quay installation tar file.
#
class quay (
  Data $version,
  String $checksum,
  Variant[Stdlib::Httpurl,String[0,0]] $http_proxy,
  Variant[Stdlib::Httpurl,String[0,0]] $https_proxy,
  String $no_proxy,
  Stdlib::Httpurl $download_source = "https://github.com/quay/quay/archive/${version}.tar.gz",
) {

  include 'docker'
  include 'docker::compose'

  if ! empty($https_proxy) or ! empty($http_proxy) {
    $_proxy_server = pick($https_proxy, $http_proxy)
  } else {
    $_proxy_server = undef
  }

  $_default_no_proxy = '127.0.0.1,localhost,.local'
  if ! empty($no_proxy) {
    $_no_proxy = "${_default_no_proxy},${no_proxy}"
  } else {
    $_no_proxy = $_default_no_proxy
  }

  class { 'quay::install':
    version         => $version,
    checksum        => $checksum,
    download_source => $download_source,
    proxy_server    => $_proxy_server,
  }
  contain 'quay::install'

  class { 'quay::config':
  }
  contain 'quay::config'

  class { 'quay::service':
  }
  contain 'quay::service'

  Class['quay::install']
  -> Class['quay::config']
  -> Class['quay::service']

}
