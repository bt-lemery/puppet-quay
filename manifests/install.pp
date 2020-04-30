# @api private
# @summary Download quay and install into `/opt/quay`
class quay::install (
  $version,
  $checksum,
  $download_source,
  $proxy_server = undef,
){

  assert_private()

  file { "/opt/quay-${version}":
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   =>  '0755',
  }

  archive { "/tmp/${version}.tar.gz":
    ensure        => present,
    extract       => true,
    extract_path  => "/opt/quay-${version}",
    source        => $download_source,
    checksum      => $checksum,
    checksum_type => 'md5',
    creates       => "/opt/quay-${version}/quay",
    cleanup       => true,
    proxy_server  => $proxy_server,
    require       => File["/opt/quay-${version}"],
  }

  file { '/opt/quay':
    ensure    => link,
    target    => "/opt/quay-${version}/quay",
    subscribe => Archive["/tmp/${version}.tar.gz"],
  }

}
